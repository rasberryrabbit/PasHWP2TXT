program HWP2TXT;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp
  { you can add units after this }
  ,uhwpfile,FileUtil,LazUTF8Classes;

var
  outFile:TFileStreamUTF8;
  ifile,ofile,outstr,query,path,wfile:string;
  findrec:TSearchRec;

type

  { THwpTxtConsole }

  THwpTxtConsole = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ THwpTxtConsole }

procedure THwpTxtConsole.DoRun;
var
  i:integer;
  temp:string;
  writeflag:Boolean;
begin
  writeln('*** HWP to TXT converter 0.03 ***');

  ifile:='';

  for i:=1 to ParamCount do begin
    temp:=ParamStrUTF8(i);
    if (temp<>'') and (temp[1]<>'-') then begin
      ifile:=temp;
      break;
    end;
  end;

  if ifile<>'' then begin
    path:=ExtractFilePath(pchar(ifile));
    wfile:=ExtractFileName(pchar(ifile));

    i:=FindFirstUTF8(pchar(ifile),faAnyFile,findrec);
    if i<>-1 then begin
      while i=0 do begin
        if (findrec.Attr and faDirectory)=0 then begin
        wfile:=path+pchar(findrec.Name);

        if FileExistsUTF8(wfile) then begin
          try
            ofile:=ChangeFileExt(pchar(wfile),'-conv.txt');

            outstr:=UTF8Encode(ReadHWPText(wfile));
            {
            hwpfile:=THWPFile.Create;
            try
              hwpfile.Open(wfile);
              outstr:=UTF8Encode(hwpfile.Text);
            finally
              hwpfile.Free;
            end;
            }

            writeflag:=True;
            if FileExistsUTF8(ofile) then begin
              if HasOption('s') then
                writeflag:=False
                else
                  if (not HasOption('w')) then begin
                    Write('File '+Utf8ToAnsi(ExtractFileName(ofile))+' already exist. overwrite(y/n)?');
                    readln(query);
                    if (query<>'Y') and (query<>'y') then
                      writeflag:=False;
                  end;
            end;

            if writeflag then begin
              outFile:=TFileStreamUTF8.Create(pchar(ofile),fmCreate or fmOpenWrite or fmShareExclusive);
              try
                outFile.Write(outstr[1],length(outstr));
              finally
                outFile.Free;
              end;
              WriteLn(Utf8ToAnsi(ExtractFileName(ofile))+' created.');
            end else
              WriteLn(Utf8ToAnsi(ExtractFileName(ofile))+' skipped.');
          except
            on e:exception do
              WriteLn(e.Message);
          end;
        end else
          WriteLn('File not found.');
        end;
        i:=FindNextUTF8(findrec);
      end;
      FindCloseUTF8(findrec);
    end;

  end else
    WriteHelp;

  // stop program loop
  Terminate;
end;

constructor THwpTxtConsole.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor THwpTxtConsole.Destroy;
begin
  inherited Destroy;
end;

procedure THwpTxtConsole.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: HWP2TXT <HWP file> [-w|-s]');
  writeln('HWP97 or higher supported.');
  writeln(' -w : Force overwrite output file.');
  writeln(' -s : skip if already exist output file.');
end;

var
  Application: THwpTxtConsole;
begin
  Application:=THwpTxtConsole.Create(nil);
  Application.Title:='HWPTXT';
  Application.Run;
  Application.Free;
end.

