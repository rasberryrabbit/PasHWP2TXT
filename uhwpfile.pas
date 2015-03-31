unit uhwpfile;

{
     HWP 97 File Text Extractor.

     fpspreadsheet library required(only OLE File support).

     Copyright 2013 Do-wan Kim.
}

{$mode objfpc}{$H+}

{.$DEFINE UNICODE_FILE}

interface

uses
  Classes, SysUtils;

type

  THWPFileHeader=packed record
    Header:array[0..31] of byte; // 'HWP Document File'#0
    Version:DWord;
    Prop:DWord;
    Reserved:Array[0..215] of byte;
  end;

  { THWPFile5 }

  THWPFile5 = class(TObject)
    private
      FHeader:THWPFileHeader;
      FBodyText:TMemoryStream;
      FDocInfo:TMemoryStream;
      FHWPText:WideString;

      function GetCompressed:Boolean;
      function GetHWPVersion:longword;
      function GetHWPProtect:Boolean;
    protected
      function GetSectionCount:Integer;
      function GetParaText: WideString;
    public
      constructor Create;
      destructor Destroy; override;

      function Open(AFilename: string): Boolean;

      property Compressed:Boolean read GetCompressed;
      property Version:longword read GetHWPVersion;
      property Protect:Boolean read GetHWPProtect;
      property Text:WideString read FHWPText;
  end;

  THWPInfo3 = packed record
    x,y:word;
    papertype,paperori:byte;
    paperinfo:array[0..8] of word;
    docnoedit:longword;
    docconv:word;
    doccon:array[0..1] of byte;
    doconname:array[0..39] of byte;
    docdesc:array[0..23] of byte;
    docprotected:word;
    docinitpageno:word;
    docfootnoteinfo:array[0..4] of word;
    footnotechar:char;
    footnotewidth:byte;
    docborder:array[0..3] of word;
    bordertype:word;
    skipemptyline:byte;
    movableframe:byte;
    compress:byte;
    revision:byte;
    infoblocklen:word;
    // 128 bytes
  end;

  THWPDocSummary3=packed record
    doctitle:array[0..55] of word;
    docobj:array[0..55] of word;
    docauthor:array[0..55] of word;
    docdate:array[0..55] of word;
    dockeyword:array[0..1,0..55] of word;
    docmisc:array[0..2,0..55] of word;
    // 1008 bytes
  end;

  THWPCharShape3=packed record
    data:array[0..30] of byte;
  end;

  THWPParaHeader3=packed record
    prevpara:byte;
    hcharLen:word;
    line:word;
    incudecharshape:byte;
    flag:byte;
    specchar:longword;
    style:byte;
    charshape:THWPCharShape3;
  end;

  THWPParaLineInfo3=packed record
    pos:word;
    info:array[0..1] of word;
    Reserved:array[0..5] of byte;
    LineType:word;
    // 14 bytes
  end;

  THWPParaShape3=packed record
    data:array[0..186] of byte;
  end;

  { THWPFile3 }

  THWPFile3 = class(TObject)
    private
      FDocHeader:array[0..29] of byte;
      FDocInfo:THWPInfo3;
      FDocSummary:THWPDocSummary3;

      FBlock:TMemoryStream;
      FParaHeader:THWPParaHeader3;

      FText:WideString;

      function GetHwpCompressed:Boolean;
      function GetHwpProtected:Boolean;
    protected
      function ConvertUnicode:WideString;
    public

      constructor Create;
      destructor Destroy; override;

      function Open(AFilename:string):Boolean;

      property Compressed:Boolean read GetHwpCompressed;
      property Protect:Boolean read GetHwpProtected;
      property Text:WideString read FText;
  end;

function ReadHWPText(AFilename:string):WideString;

implementation

uses uvirtuallayer, uvirtuallayer_ole, uvirtuallayer_stream, zstream
     {$IFDEF UNICODE_FILE},FileUtil,LazUTF8Classes{$ENDIF},ukssmunicode;

type
  EHWPReaderError=Exception;

  { TUnzlibStream }

  TUnzlibStream=class(Tdecompressionstream)
    public
      function read(var buffer; count: longint): longint; override;
  end;

const
  _HWPHeader = 'HWP Document File'#0;
  _HWPHeader3:array[0..29] of byte=($48,$57,$50,$20,$44,$6F,$63,$75,$6D,$65,$6E,$74,$20,$46,$69,
                                    $6C,$65,$20,$56,$33,$2E,$30,$30,$20,$1A,$01,$02,$03,$04,$05);
  HWPTAG_BEGIN=$010;

procedure UnpackData(ASource, ADest: TStream);
var
  compstream:TUnzlibStream;
  buf:TMemoryStream;
  plen:PLongWord;
begin
  buf:=TMemoryStream.Create;
  try
    buf.CopyFrom(ASource,ASource.Size);
    plen:=buf.Memory+(buf.Size-4);
    compstream:=TUnzlibStream.create(buf,True);
    try
      buf.Position:=0;
      ADest.CopyFrom(compstream,plen^);
    finally
      compstream.Free;
    end;
  finally
    buf.Free;
  end;
end;

function ReadHWPText(AFilename: string): WideString;
var
  HWP3:THWPFile3;
  HWP5:THWPFile5;
begin
  Result:='';
  HWP3:=THWPFile3.Create;
  try
    if HWP3.Open(AFilename) then begin
      Result:=HWP3.Text;
      exit;
    end;
  finally
    HWP3.Free;
  end;

  HWP5:=THWPFile5.Create;
  try
    if HWP5.Open(AFilename) then
      Result:=HWP5.Text;
  finally
    HWP5.Free;
  end;
end;

{ TUnzlibStream }

function TUnzlibStream.read(var buffer; count: longint): longint;
var
  RetBuf:PByte;
begin
  RetBuf:=@buffer;
  Result:=0;
  while Result<count do begin
    if 0=inherited read(RetBuf^,1) then
      break;
    Inc(Result);
    Inc(RetBuf);
  end;
end;


{ THWPFile3 }

function THWPFile3.GetHwpCompressed: Boolean;
begin
  Result:=FDocInfo.compress<>0;
end;

function THWPFile3.GetHwpProtected: Boolean;
begin
  Result:=FDocInfo.docprotected<>0;
end;

function THWPFile3.ConvertUnicode: WideString;
const
  _bufsize=1023;
var
  code:word;
  buf:array[0.._bufsize] of WideChar;
  lastRead:Integer;
begin
  Result:='';
  FBlock.Position:=0;
  while True do begin
    FillChar(buf,sizeof(buf),0);
    LastRead:=FBlock.Read(buf,_bufsize*sizeof(word));
    if lastRead=0 then
      break;
    lastRead:=lastRead div sizeof(word);
    while lastRead>0 do begin
      Dec(lastRead);
      code:=word(buf[lastRead]);
      if code>255 then
        buf[lastRead]:=WideChar(KSSM2UNICODE(code));
    end;
    Result:=Result+buf;
  end;
end;

constructor THWPFile3.Create;
begin
  inherited;
  FBlock:=TMemoryStream.Create;
end;

destructor THWPFile3.Destroy;
begin
  FBlock.Free;
  inherited Destroy;
end;

procedure ReadDummy(Stream:TStream;Count:Integer);
var
  i:Integer;
  dummy:byte;
begin
  for i:=1 to Count do
    Stream.Read(dummy,1);
end;

function THWPFile3.Open(AFilename: string): Boolean;
var
  RealFile:{$IFDEF UNICODE_FILE}TFileStreamUTF8{$ELSE}TFileStream{$ENDIF};
  CompStream:TUnzlibStream;
  Stream:TStream;
  len,i,j:word;

  function parseParaText:Boolean;
  var
    hchar: word;
    paraflag: byte;
    len,i,j,cells: word;
    datalen:longword;
  begin
    Result:=False;

    while True do begin
      if sizeof(THWPParaHeader3)<>Stream.Read(FParaHeader,sizeof(THWPParaHeader3)) then
        raise EHWPReaderError.Create('Read Error');

      if (FParaHeader.prevpara=0) and (FParaHeader.hcharLen>0) then
        ReadDummy(Stream,sizeof(THWPParaShape3));

      if FParaHeader.hcharLen=0 then
        exit;

      // mark new line.
      if FBlock.Size<>0 then begin
        len:=13;
        FBlock.Write(len,2);
      end;

      for i:=1 to FParaHeader.line do
        ReadDummy(Stream,sizeof(THWPParaLineInfo3));

      if FParaHeader.incudecharshape<>0 then
        for i:=1 to FParaHeader.hcharLen do begin
          Stream.Read(paraflag,1);
          if paraflag<>1 then
            ReadDummy(Stream,sizeof(THWPCharShape3));
        end;

      // text
      i:=0;
      len:=FParaHeader.hcharLen;
      while i<len do begin
        Stream.Read(hchar,2);
        Inc(i);
        if hchar<32 then begin
          case hchar of
          6: begin   // bookmark
               Inc(i,3);
               ReadDummy(Stream,6);
               ReadDummy(Stream,34);
             end;
          7: begin
               Inc(i,41);//?
               ReadDummy(Stream,82);
             end;
          8: begin
               Inc(i,47);//?
               ReadDummy(Stream,94);
             end;
          9: begin  // tab
               Inc(i,3);
               ReadDummy(Stream,6);
               hchar:=9;
               FBlock.Write(hchar,2);
             end;
          10: begin // table
               Inc(i,3);
               ReadDummy(Stream,6);

               ReadDummy(Stream,80);
               Stream.Read(cells,2);
               ReadDummy(Stream,2);

               ReadDummy(Stream,27*cells);

               // table cell
               for j:=1 to cells do
                 while parseParaText() do begin
                 end;

               // table caption
               while parseParaText() do begin
               end;
              end;
          11: begin // picutre
               Inc(i,3);
               ReadDummy(Stream,6);
               Stream.Read(datalen,4);
               ReadDummy(Stream,344);
               ReadDummy(Stream,datalen);
               //caption
               while parseParaText() do begin
               end;
              end;
          13: ;
          14: begin
               Inc(i,3);
               ReadDummy(Stream,6);
               ReadDummy(Stream,84);
              end;
          15: begin
               Inc(i,3);
               ReadDummy(Stream,6);
               ReadDummy(Stream,8);
               while parseParaText() do begin
               end;
              end;
          16: begin
               Inc(i,3);
               ReadDummy(Stream,6);
               ReadDummy(Stream,10);
               while parseParaText() do begin
               end;
              end;
          17: begin
               Inc(i,3);
               ReadDummy(Stream,6);
               ReadDummy(Stream,14);
               while parseParaText() do begin
               end;
              end;
          18,19,20,21:
              begin
               Inc(i,3);
               ReadDummy(Stream,6);
              end;
          22: begin //?
               Inc(i,11);
               ReadDummy(Stream,22);
              end;
          23: begin
               Inc(i,4);
               ReadDummy(Stream,8);
              end;
          24,25:
              begin
                Inc(i,2);
                ReadDummy(Stream,4);
                if hchar=24 then begin
                  hchar:=word('-');
                  FBlock.Write(hchar,2);
                end;
              end;
          26: begin //?
                Inc(i,122);
                ReadDummy(Stream,244);
              end;
          28: begin
                Inc(i,31);
                ReadDummy(Stream,62);
              end;
          30,31:
              begin
                Inc(i,1);
                ReadDummy(Stream,2);
                hchar:=9;
                FBlock.Write(hchar,2);
              end;
          5,29:
              begin //?
                Inc(i,3);
                Stream.Read(datalen,4);
                ReadDummy(Stream,2);
                ReadDummy(Stream,datalen);
              end;
          end
        end else
          FBlock.Write(hchar,2);
      end;
    end;
    Result:=True;
  end;

begin
  Result:=False;
  FBlock.Clear;
  FillChar(FDocHeader,sizeof(THWPInfo3),0);
  FillChar(FDocSummary,sizeof(THWPDocSummary3),0);
  FText:='';

  if {$IFDEF UNICODE_FILE}FileExistsUTF8{$ELSE}FileExists{$ENDIF}(AFilename) then begin
    RealFile:={$IFDEF UNICODE_FILE}TFileStreamUTF8{$ELSE}TFileStream{$ENDIF}.Create(AFilename,fmOpenRead or fmShareDenyWrite);
    try
      // header
      if 30<>RealFile.Read(FDocHeader[0],30) then
        raise EHWPReaderError.Create('Read Error')
        else if not CompareMem(@FDocHeader[0],@_HWPHeader3[0],30) then
          exit;
      // info
      if sizeof(THWPInfo3)<>RealFile.Read(FDocInfo.x,sizeof(THWPInfo3)) then
        raise EHWPReaderError.Create('Read Error');
      // desc
      if sizeof(THWPDocSummary3)<>RealFile.Read(FDocSummary.doctitle[0],sizeof(THWPDocSummary3)) then
        raise EHWPReaderError.Create('Read Error');
      // info block #0
      ReadDummy(RealFile,FDocInfo.infoblocklen);
      // compressed?
      if Compressed then begin
        CompStream:=TUnzlibStream.create(RealFile,True);
        Stream:=CompStream;
      end else
        Stream:=RealFile;
      // font face
      for i:=1 to 7 do begin
        Stream.Read(len,2);
        for j:=1 to len do
          ReadDummy(Stream,40);
      end;
      // style
      Stream.Read(len,2);
      for i:=1 to len do
        ReadDummy(Stream,238);

      // para
      while parseParaText() do begin
      end;

      FText:=FText+ConvertUnicode;
      Result:=True;
    finally
      if Compressed then
        CompStream.Free;
      RealFile.Free;
    end;
  end;
end;

{ THWPFile5 }

constructor THWPFile5.Create;
begin
  inherited;
  FBodyText:=TMemoryStream.Create;
  FDocInfo:=TMemoryStream.Create;
  FillChar(FHeader,sizeof(THWPFileHeader),0);
end;

destructor THWPFile5.Destroy;
begin
  FBodyText.Free;
  FDocInfo.Free;
  inherited Destroy;
end;

function THWPFile5.GetCompressed: Boolean;
begin
  Result:=FHeader.Prop and 1<>0;
end;

function THWPFile5.GetHWPVersion: longword;
begin
  Result:=FHeader.Version;
end;

function THWPFile5.GetHWPProtect: Boolean;
begin
  Result:=FHeader.Prop and 2<>0;
end;

function THWPFile5.GetSectionCount: Integer;
const
  HWPTAG_DOC_PROP=HWPTAG_BEGIN;
var
  Head:Longword;
  pinc,i:Integer;
  dummy:byte;
  retw:Word;
begin
  Result:=0;
  //FDocInfo.SaveToFile('dump_docinfo.bin'); // debug
  FDocInfo.Position:=0;
  while FDocInfo.Position<FDocInfo.Size do begin
    FDocInfo.Read(Head,4);
    pinc:=Head shr 20;
    if pinc=$0FFF then
      FDocInfo.Read(pinc,4);
    if (Head and $3ff)=HWPTAG_DOC_PROP then begin
      FDocInfo.Read(retw,2);
      Result:=retw;
      break;
    end;
    for i:=1 to pinc do
      FDocInfo.Read(dummy,1);
  end;
end;

function THWPFile5.GetParaText: WideString;
const
  HWPTAG_PARA_HEADER=HWPTAG_BEGIN+50;
  HWPTAG_PARA_TEXT=HWPTAG_BEGIN+51;
var
  Head:Longword;
  pinc,i:Integer;
  dummy:byte;
  processed:Boolean;
  stemp:WideString;
  whtemp:WideChar;
  cbuf:array[0..6] of WideChar;
  (*
  ff:TFileStream;
  sstemp:string;
  *)
begin
  Result:='';
  FBodyText.Position:=0;
  //FBodyText.SaveToFile('dump_body.bin'); // debug
  while FBodyText.Position<FBodyText.Size do begin
    processed:=False;
    FBodyText.Read(Head,4);
    pinc:=Head shr 20;
    if pinc=$0FFF then
      FBodyText.Read(pinc,4);
    if (Head and $3ff)=HWPTAG_PARA_TEXT then begin
      i:=0;
      stemp:='';
      while i<pinc do begin
        FBodyText.Read(whtemp,2);
        // check control char
        if whtemp<#32 then begin;
          case word(whtemp) of
          0,10,13,25,26,27,28,29: ;
          4,5,6,7,8,19,20:   begin
                               FBodyText.Read(cbuf[0],sizeof(cbuf));
                               Inc(i,sizeof(cbuf));
                             end;
          1,2,3,11,12,14,15,16,17,18,21,22,23: begin
                               FBodyText.Read(cbuf[0],sizeof(cbuf));
                               Inc(i,sizeof(cbuf));
                             end;
          9: begin
            FBodyText.Read(cbuf[0],sizeof(cbuf));
            Inc(i,sizeof(cbuf));
            stemp:=stemp+#9;
             end;
          24: stemp:=stemp+'-';
          30,31: stemp:=stemp+' ';
          end;
        end else
          stemp:=stemp+whtemp;
        Inc(i,2);
      end;
      Result:=Result+stemp;
      processed:=True;
    end else begin
      //Result:=Result+#13+Format('%x ; %d',[Head and $3ff,pinc]); // debug
      // linebreak
      if Head and $3FF=HWPTAG_PARA_HEADER then begin
        if Result<>'' then
          Result:=Result+LineEnding;
      end;
    end;
    // skip bytes
    if not processed then
      for i:=1 to pinc do
        FBodyText.Read(dummy,1);
  end;

  (*
  ff:=TFileStream.Create('dump_code.txt',fmCreate or fmOpenWrite);
  try
    for i:=1 to Length(Result) do begin
      sstemp:='$'+IntToHex(Word(Result[i]),4)+',';
      ff.Write(sstemp[1],Length(sstemp));
    end;
  finally
    ff.Free;
  end;
  *)
end;

function THWPFile5.Open(AFilename: string): Boolean;
var
  olefs:TVirtualLayer_OLE;
  i,Section:Integer;
  RealFile:{$IFDEF UNICODE_FILE}TFileStreamUTF8{$ELSE}TFileStream{$ENDIF};
  vFile:TVirtualLayer_Stream;
  vFilename:string;
begin
  Result:=False;
  FHWPText:='';
  FillChar(FHeader,sizeof(THWPFileHeader),0);
  FBodyText.Clear;
  FDocInfo.Clear;

  if {$IFDEF UNICODE_FILE}FileExistsUTF8{$ELSE}FileExists{$ENDIF}(AFilename) then begin
    RealFile:={$IFDEF UNICODE_FILE}TFileStreamUTF8{$ELSE}TFileStream{$ENDIF}.Create(AFilename,fmOpenRead or fmShareDenyWrite);
    try
      olefs:=TVirtualLayer_OLE.Create(RealFile);
      try
        olefs.Initialize();
        // header check
        vFilename:='/FileHeader';
        if olefs.FileExists(vFilename) then begin
          vFile:=olefs.CreateStream(vFilename,fmOpenRead);
          try
            if sizeof(THWPFileHeader)<>vFile.Read(FHeader,sizeof(THWPFileHeader)) then
               raise EHWPReaderError.Create('Read Error')
               else
                 if strlcomp(@FHeader.Header[0],pchar(_HWPHeader),sizeof(_HWPHeader))<>0 then
                    raise EHWPReaderError.Create('Bad Header');
          finally
            vFile.Free;
          end;
        end else
          raise EHWPReaderError.Create('Bad File');

        if Protect then
          raise EHWPReaderError.Create('Cannot work with protected file.');

        // read doc info
        vFilename:='/DocInfo';
        if olefs.FileExists(vFilename) then begin
          vFile:=olefs.CreateStream(vFilename,fmOpenRead);
          try
            if Compressed then
               UnpackData(vFile,FDocInfo)
               else
                 FDocInfo.CopyFrom(vFile,vFile.Size);
            Section:=GetSectionCount;
            //to do
            FDocInfo.Clear;
          finally
            vFile.Free;
          end;
        end;

        // read text section
        i:=0;
        repeat
          vFilename:=Format('/BodyText/Section%d',[i]);
          if olefs.FileExists(vFilename) then begin
            vFile:=olefs.CreateStream(vFilename,fmOpenRead);
            try
              if Compressed then
                UnpackData(vFile,FBodyText)
                else
                  FBodyText.CopyFrom(vFile,vFile.Size);
              // split sections
              if FHWPText<>'' then
                FHWPText:=FHWPText+LineEnding;
              FHWPText:=FHWPText+GetParaText;
              // to do
              FBodyText.Clear;
            finally
              vFile.Free;
            end;
          end;
          Inc(i);
        until i>=Section;

        Result:=True;
      finally
        olefs.Free;
      end;
    finally
      RealFile.Free;
    end;
  end;
end;

end.

