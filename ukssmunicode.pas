unit ukssmunicode;

{
     HanCom code to unicode.

     hanja is only supported 4888 characters in standard.

     Copyright 2013 Do-wan Kim.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


function KSSM2UNICODE(code:word):word;
function UNICODE2KSSM(code:word):word;


implementation


const
  // UNICODE > KSSM
  table_uni_cho:array[0..18] of integer =
  (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20);
  table_uni_jung:array[0..20] of integer =
  (3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 18, 19, 20 ,21, 22, 23, 26, 27, 28, 29);
  table_uni_jong:array[0..27] of integer =
  (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,16, 17, 19, 20, 21, 22, 23, 24,
  25, 26, 27, 28, 29);
  // KSSM > UNICODE
  table_kssm_cho:array[0..20] of integer =
  (0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18);
  table_kssm_jung:array[0..29] of integer =
  (0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 5, 6, 7, 8 ,9, 10, 0, 0, 11, 12, 13, 14, 15, 16, 0, 0, 17, 18, 19, 20);
  table_kssm_jong:array[0..29] of integer =
  (0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 0, 17, 18, 19, 20, 21, 22,
  23, 24, 25, 26, 27);

const
	johabhanja:array [0..4887] of word=(
	$4F3D,$4F73,$5047,$50F9,$52A0,$53EF,$5475,$54E5,$5609,$5AC1,$5BB6,$6687,$67B6,$67B7,$67EF,$6B4C,
	$73C2,$75C2,$7A3C,$82DB,$8304,$8857,$8888,$8A36,$8CC8,$8DCF,$8EFB,$8FE6,$99D5,$523B,$5374,$5404,
	$606A,$6164,$6BBC,$73CF,$811A,$89BA,$89D2,$95A3,$4F83,$520A,$58BE,$5978,$59E6,$5E72,$5E79,$61C7,
	$63C0,$6746,$67EC,$687F,$6F97,$764E,$770B,$78F5,$7A08,$7AFF,$7C21,$809D,$826E,$8271,$8AEB,$9593,
	$4E6B,$559D,$66F7,$6E34,$78A3,$7AED,$845B,$8910,$874E,$97A8,$52D8,$574E,$582A,$5D4C,$611F,$61BE,
	$6221,$6562,$67D1,$6A44,$6E1B,$7518,$75B3,$76E3,$77B0,$7D3A,$90AF,$9451,$9452,$9F95,$5323,$5CAC,
	$7532,$80DB,$9240,$9598,$525B,$5808,$59DC,$5CA1,$5D17,$5EB7,$5F3A,$5F4A,$6177,$6C5F,$757A,$7586,
	$7CE0,$7D73,$7DB1,$7F8C,$8154,$8221,$8591,$8941,$8B1B,$92FC,$964D,$9C47,$4ECB,$4EF7,$500B,$51F1,
	$584F,$6137,$613E,$6168,$6539,$69EA,$6F11,$75A5,$7686,$76D6,$7B87,$82A5,$84CB,$F900,$93A7,$958B,
	$5580,$5BA2,$5751,$F901,$7CB3,$7FB9,$91B5,$5028,$53BB,$5C45,$5DE8,$62D2,$636E,$64DA,$64E7,$6E20,
	$70AC,$795B,$8DDD,$8E1E,$F902,$907D,$9245,$92F8,$4E7E,$4EF6,$5065,$5DFE,$5EFA,$6106,$6957,$8171,
	$8654,$8E47,$9375,$9A2B,$4E5E,$5091,$6770,$6840,$5109,$528D,$5292,$6AA2,$77BC,$9210,$9ED4,$52AB,
	$602F,$8FF2,$5048,$61A9,$63ED,$64CA,$683C,$6A84,$6FC0,$8188,$89A1,$9694,$5805,$727D,$72AC,$7504,
	$7D79,$7E6D,$80A9,$898B,$8B74,$9063,$9D51,$6289,$6C7A,$6F54,$7D50,$7F3A,$8A23,$517C,$614A,$7B9D,
	$8B19,$9257,$938C,$4EAC,$4FD3,$501E,$50BE,$5106,$52C1,$52CD,$537F,$5770,$5883,$5E9A,$5F91,$6176,
	$61AC,$64CE,$656C,$666F,$66BB,$66F4,$6897,$6D87,$7085,$70F1,$749F,$74A5,$74CA,$75D9,$786C,$78EC,
	$7ADF,$7AF6,$7D45,$7D93,$8015,$803F,$811B,$8396,$8B66,$8F15,$9015,$93E1,$9803,$9838,$9A5A,$9BE8,
	$4FC2,$5553,$583A,$5951,$5B63,$5C46,$60B8,$6212,$6842,$68B0,$68E8,$6EAA,$754C,$7678,$78CE,$7A3D,
	$7CFB,$7E6B,$7E7C,$8A08,$8AA1,$8C3F,$968E,$9DC4,$53E4,$53E9,$544A,$5471,$56FA,$59D1,$5B64,$5C3B,
	$5EAB,$62F7,$6537,$6545,$6572,$66A0,$67AF,$69C1,$6CBD,$75FC,$7690,$777E,$7A3F,$7F94,$8003,$80A1,
	$818F,$82E6,$82FD,$83F0,$85C1,$8831,$88B4,$8AA5,$F903,$8F9C,$932E,$96C7,$9867,$9AD8,$9F13,$54ED,
	$659B,$66F2,$688F,$7A40,$8C37,$9D60,$56F0,$5764,$5D11,$6606,$68B1,$68CD,$6EFE,$7428,$889E,$9BE4,
	$6C68,$F904,$9AA8,$4F9B,$516C,$5171,$529F,$5B54,$5DE5,$6050,$606D,$62F1,$63A7,$653B,$73D9,$7A7A,
	$86A3,$8CA2,$978F,$4E32,$5BE1,$6208,$679C,$74DC,$79D1,$83D3,$8A87,$8AB2,$8DE8,$904E,$934B,$9846,
	$5ED3,$69E8,$85FF,$90ED,$F905,$51A0,$5B98,$5BEC,$6163,$68FA,$6B3E,$704C,$742F,$74D8,$7BA1,$7F50,
	$83C5,$89C0,$8CAB,$95DC,$9928,$522E,$605D,$62EC,$9002,$4F8A,$5149,$5321,$58D9,$5EE3,$66E0,$6D38,
	$709A,$72C2,$73D6,$7B50,$80F1,$945B,$5366,$639B,$7F6B,$4E56,$5080,$584A,$58DE,$602A,$6127,$62D0,
	$69D0,$9B41,$5B8F,$7D18,$80B1,$8F5F,$4EA4,$50D1,$54AC,$55AC,$5B0C,$5DA0,$5DE7,$652A,$654E,$6821,
	$6A4B,$72E1,$768E,$77EF,$7D5E,$7FF9,$81A0,$854E,$86DF,$8F03,$8F4E,$90CA,$9903,$9A55,$9BAB,$4E18,
	$4E45,$4E5D,$4EC7,$4FF1,$5177,$52FE,$5340,$53E3,$53E5,$548E,$5614,$5775,$57A2,$5BC7,$5D87,$5ED0,
	$61FC,$62D8,$6551,$67B8,$67E9,$69CB,$6B50,$6BC6,$6BEC,$6C42,$6E9D,$7078,$72D7,$7396,$7403,$77BF,
	$77E9,$7A76,$7D7F,$8009,$81FC,$8205,$820A,$82DF,$8862,$8B33,$8CFC,$8EC0,$9011,$90B1,$9264,$92B6,
	$99D2,$9A45,$9CE9,$9DD7,$9F9C,$570B,$5C40,$83CA,$97A0,$97AB,$9EB4,$541B,$7A98,$7FA4,$88D9,$8ECD,
	$90E1,$5800,$5C48,$6398,$7A9F,$5BAE,$5F13,$7A79,$7AAE,$828E,$8EAC,$5026,$5238,$52F8,$5377,$5708,
	$62F3,$6372,$6B0A,$6DC3,$7737,$53A5,$7357,$8568,$8E76,$95D5,$673A,$6AC3,$6F70,$8A6D,$8ECC,$994B,
	$F906,$6677,$6B78,$8CB4,$9B3C,$F907,$53EB,$572D,$594E,$63C6,$69FB,$73EA,$7845,$7ABA,$7AC5,$7CFE,
	$8475,$898F,$8D73,$9035,$95A8,$52FB,$5747,$7547,$7B60,$83CC,$921E,$F908,$6A58,$514B,$524B,$5287,
	$621F,$68D8,$6975,$9699,$50C5,$52A4,$52E4,$61C3,$65A4,$6839,$69FF,$747E,$7B4B,$82B9,$83EB,$89B2,
	$8B39,$8FD1,$9949,$F909,$4ECA,$5997,$64D2,$6611,$6A8E,$7434,$7981,$79BD,$82A9,$887E,$887F,$895F,
	$F90A,$9326,$4F0B,$53CA,$6025,$6271,$6C72,$7D1A,$7D66,$4E98,$5162,$77DC,$80AF,$4F01,$4F0E,$5176,
	$5180,$55DC,$5668,$573B,$57FA,$57FC,$5914,$5947,$5993,$5BC4,$5C90,$5D0E,$5DF1,$5E7E,$5FCC,$6280,
	$65D7,$65E3,$671E,$671F,$675E,$68CB,$68C4,$6A5F,$6B3A,$6C23,$6C7D,$6C82,$6DC7,$7398,$7426,$742A,
	$7482,$74A3,$7578,$757F,$7881,$78EF,$7941,$7947,$7948,$797A,$7B95,$7D00,$7DBA,$7F88,$8006,$802D,
	$808C,$8A18,$8B4F,$8C48,$8D77,$9321,$9324,$98E2,$9951,$9A0E,$9A0F,$9A65,$9E92,$7DCA,$4F76,$5409,
	$62EE,$6854,$91D1,$55AB,$513A,$F90B,$F90C,$5A1C,$61E6,$F90D,$62CF,$62FF,$F90E,$F90F,$F910,$F911,
	$F912,$F913,$90A3,$F914,$F915,$F916,$F917,$F918,$8AFE,$F919,$F91A,$F91B,$F91C,$6696,$F91D,$7156,
	$F91E,$F91F,$96E3,$F920,$634F,$637A,$5357,$F921,$678F,$6960,$6E73,$F922,$7537,$F923,$F924,$F925,
	$7D0D,$F926,$F927,$8872,$56CA,$5A18,$F928,$F929,$F92A,$F92B,$F92C,$4E43,$F92D,$5167,$5948,$67F0,
	$8010,$F92E,$5973,$5E74,$649A,$79CA,$5FF5,$606C,$62C8,$637B,$5BE7,$5BD7,$52AA,$F92F,$5974,$5F29,
	$6012,$F930,$F931,$F932,$7459,$F933,$F934,$F935,$F936,$F937,$F938,$99D1,$F939,$F93A,$F93B,$F93C,
	$F93D,$F93E,$F93F,$F940,$F941,$F942,$F943,$6FC3,$F944,$F945,$81BF,$8FB2,$60F1,$F946,$F947,$8166,
	$F948,$F949,$5C3F,$F94A,$F94B,$F94C,$F94D,$F94E,$F94F,$F950,$F951,$5AE9,$8A25,$677B,$7D10,$F952,
	$F953,$F954,$F955,$F956,$F957,$80FD,$F958,$F959,$5C3C,$6CE5,$533F,$6EBA,$591A,$8336,$4E39,$4EB6,
	$4F46,$55AE,$5718,$58C7,$5F56,$65B7,$65E6,$6A80,$6BB5,$6E4D,$77ED,$7AEF,$7C1E,$7DDE,$86CB,$8892,
	$9132,$935B,$64BB,$6FBE,$737A,$75B8,$9054,$5556,$574D,$61BA,$64D4,$66C7,$6DE1,$6E5B,$6F6D,$6FB9,
	$75F0,$8043,$81BD,$8541,$8983,$8AC7,$8B5A,$931F,$6C93,$7553,$7B54,$8E0F,$905D,$5510,$5802,$5858,
	$5E62,$6207,$649E,$68E0,$7576,$7CD6,$87B3,$9EE8,$4EE3,$5788,$576E,$5927,$5C0D,$5CB1,$5E36,$5F85,
	$6234,$64E1,$73B3,$81FA,$888B,$8CB8,$968A,$9EDB,$5B85,$5FB7,$60B3,$5012,$5200,$5230,$5716,$5835,
	$5857,$5C0E,$5C60,$5CF6,$5D8B,$5EA6,$5F92,$60BC,$6311,$6389,$6417,$6843,$68F9,$6AC2,$6DD8,$6E21,
	$6ED4,$6FE4,$71FE,$76DC,$7779,$79B1,$7A3B,$8404,$89A9,$8CED,$8DF3,$8E48,$9003,$9014,$9053,$90FD,
	$934D,$9676,$97DC,$6BD2,$7006,$7258,$72A2,$7368,$7763,$79BF,$7BE4,$7E9B,$8B80,$58A9,$60C7,$6566,
	$65FD,$66BE,$6C8C,$711E,$71C9,$8C5A,$9813,$4E6D,$7A81,$4EDD,$51AC,$51CD,$52D5,$540C,$61A7,$6771,
	$6850,$68DF,$6D1E,$6F7C,$75BC,$77B3,$7AE5,$80F4,$8463,$9285,$515C,$6597,$675C,$6793,$75D8,$7AC7,
	$8373,$F95A,$8C46,$9017,$982D,$5C6F,$81C0,$829A,$9041,$906F,$920D,$5F97,$5D9D,$6A59,$71C8,$767B,
	$7B49,$85E4,$8B04,$9127,$9A30,$5587,$61F6,$F95B,$7669,$7F85,$863F,$87BA,$88F8,$908F,$F95C,$6D1B,
	$70D9,$73DE,$7D61,$843D,$F95D,$916A,$99F1,$F95E,$4E82,$5375,$6B04,$6B12,$703E,$721B,$862D,$9E1E,
	$524C,$8FA3,$5D50,$64E5,$652C,$6B16,$6FEB,$7C43,$7E9C,$85CD,$8964,$89BD,$62C9,$81D8,$881F,$5ECA,
	$6717,$6D6A,$72FC,$7405,$746F,$8782,$90DE,$4F86,$5D0D,$5FA0,$840A,$51B7,$63A0,$7565,$4EAE,$5006,
	$5169,$51C9,$6881,$6A11,$7CAE,$7CB1,$7CE7,$826F,$8AD2,$8F1B,$91CF,$4FB6,$5137,$52F5,$5442,$5EEC,
	$616E,$623E,$65C5,$6ADA,$6FFE,$792A,$85DC,$8823,$95AD,$9A62,$9A6A,$9E97,$9ECE,$529B,$66C6,$6B77,
	$701D,$792B,$8F62,$9742,$6190,$6200,$6523,$6F23,$7149,$7489,$7DF4,$806F,$84EE,$8F26,$9023,$934A,
	$51BD,$5217,$52A3,$6D0C,$70C8,$88C2,$5EC9,$6582,$6BAE,$6FC2,$7C3E,$7375,$4EE4,$4F36,$56F9,$F95F,
	$5CBA,$5DBA,$601C,$73B2,$7B2D,$7F9A,$7FCE,$8046,$901E,$9234,$96F6,$9748,$9818,$9F61,$4F8B,$6FA7,
	$79AE,$91B4,$96B7,$52DE,$F960,$6488,$64C4,$6AD3,$6F5E,$7018,$7210,$76E7,$8001,$8606,$865C,$8DEF,
	$8F05,$9732,$9B6F,$9DFA,$9E75,$788C,$797F,$7DA0,$83C9,$9304,$9E7F,$9E93,$8AD6,$58DF,$5F04,$6727,
	$7027,$74CF,$7C60,$807E,$5121,$7028,$7262,$78CA,$8CC2,$8CDA,$8CF4,$96F7,$4E86,$50DA,$5BEE,$5ED6,
	$6599,$71CE,$7642,$77AD,$804A,$84FC,$907C,$9B27,$9F8D,$58D8,$5A41,$5C62,$6A13,$6DDA,$6F0F,$763B,
	$7D2F,$7E37,$851E,$8938,$93E4,$964B,$5289,$65D2,$67F3,$69B4,$6D41,$6E9C,$700F,$7409,$7460,$7559,
	$7624,$786B,$8B2C,$985E,$516D,$622E,$9678,$4F96,$502B,$5D19,$6DEA,$7DB8,$8F2A,$5F8B,$6144,$6817,
	$F961,$9686,$52D2,$808B,$51DC,$51CC,$695E,$7A1C,$7DBE,$83F1,$9675,$4FDA,$5229,$5398,$540F,$550E,
	$5C65,$60A7,$674E,$68A8,$6D6C,$7281,$72F8,$7406,$7483,$F962,$75E2,$7C6C,$7F79,$7FB8,$8389,$88CF,
	$88E1,$91CC,$91D0,$96E2,$9BC9,$541D,$6F7E,$71D0,$7498,$85FA,$8EAA,$96A3,$9C57,$9E9F,$6797,$6DCB,
	$7433,$81E8,$9716,$782C,$7ACB,$7B20,$7C92,$6469,$746A,$75F2,$78BC,$78E8,$99AC,$9B54,$9EBB,$5BDE,
	$5E55,$6F20,$819C,$83AB,$9088,$4E07,$534D,$5A29,$5DD2,$5F4E,$6162,$633D,$6669,$66FC,$6EFF,$6F2B,
	$7063,$779E,$842C,$8513,$883B,$8F13,$9945,$9C3B,$551C,$62B9,$672B,$6CAB,$8309,$896A,$977A,$4EA1,
	$5984,$5FD8,$5FD9,$671B,$7DB2,$7F54,$8292,$832B,$83BD,$8F1E,$9099,$57CB,$59B9,$5A92,$5BD0,$6627,
	$679A,$6885,$6BCF,$7164,$7F75,$8CB7,$8CE3,$9081,$9B45,$8108,$8C8A,$964C,$9A40,$9EA5,$5B5F,$6C13,
	$731B,$76F2,$76DF,$840C,$51AA,$8993,$514D,$5195,$52C9,$68C9,$6C94,$7704,$7720,$7DBF,$7DEC,$9762,
	$9EB5,$6EC5,$8511,$51A5,$540D,$547D,$660E,$669D,$6927,$6E9F,$76BF,$7791,$8317,$84C2,$879F,$9169,
	$9298,$9CF4,$8882,$4FAE,$5192,$52DF,$59C6,$5E3D,$6155,$6478,$6479,$66AE,$67D0,$6A21,$6BCD,$6BDB,
	$725F,$7261,$7441,$7738,$77DB,$8017,$82BC,$8305,$8B00,$8B28,$8C8C,$6728,$6C90,$7267,$76EE,$7766,
	$7A46,$9DA9,$6B7F,$6C92,$5922,$6726,$8499,$536F,$5893,$5999,$5EDF,$63CF,$6634,$6773,$6E3A,$732B,
	$7AD7,$82D7,$9328,$52D9,$5DEB,$61AE,$61CB,$620A,$62C7,$64AB,$65E0,$6959,$6B66,$6BCB,$7121,$73F7,
	$755D,$7E46,$821E,$8302,$856A,$8AA3,$8CBF,$9727,$9D61,$58A8,$9ED8,$5011,$520E,$543B,$554F,$6587,
	$6C76,$7D0A,$7D0B,$805E,$868A,$9580,$96EF,$52FF,$6C95,$7269,$5473,$5A9A,$5C3E,$5D4B,$5F4C,$5FAE,
	$672A,$68B6,$6963,$6E3C,$6E44,$7709,$7C73,$7F8E,$8587,$8B0E,$8FF7,$9761,$9EF4,$5CB7,$60B6,$610D,
	$61AB,$654F,$65FB,$65FC,$6C11,$6CEF,$739F,$73C9,$7DE1,$9594,$5BC6,$871C,$8B10,$525D,$535A,$62CD,
	$640F,$64B2,$6734,$6A38,$6CCA,$73C0,$749E,$7B94,$7C95,$7E1B,$818A,$8236,$8584,$8FEB,$96F9,$99C1,
	$4F34,$534A,$53CD,$53DB,$62CC,$642C,$6500,$6591,$69C3,$6CEE,$6F58,$73ED,$7554,$7622,$76E4,$76FC,
	$78D0,$78FB,$792C,$7D46,$822C,$87E0,$8FD4,$9812,$98EF,$52C3,$62D4,$64A5,$6E24,$6F51,$767C,$8DCB,
	$91B1,$9262,$9AEE,$9B43,$5023,$508D,$574A,$59A8,$5C28,$5E47,$5F77,$623F,$653E,$65B9,$65C1,$6609,
	$678B,$699C,$6EC2,$78C5,$7D21,$80AA,$8180,$822B,$82B3,$84A1,$868C,$8A2A,$8B17,$90A6,$9632,$9F90,
	$500D,$4FF3,$F963,$57F9,$5F98,$62DC,$6392,$676F,$6E43,$7119,$76C3,$80CC,$80DA,$88F4,$88F5,$8919,
	$8CE0,$8F29,$914D,$966A,$4F2F,$4F70,$5E1B,$67CF,$6822,$767D,$767E,$9B44,$5E61,$6A0A,$7169,$71D4,
	$756A,$F964,$7E41,$8543,$85E9,$98DC,$4F10,$7B4F,$7F70,$95A5,$51E1,$5E06,$68B5,$6C3E,$6C4E,$6CDB,
	$72AF,$7BC4,$8303,$6CD5,$743A,$50FB,$5288,$58C1,$64D8,$6A97,$74A7,$7656,$78A7,$8617,$95E2,$9739,
	$F965,$535E,$5F01,$8B8A,$8FA8,$8FAF,$908A,$5225,$77A5,$9C49,$9F08,$4E19,$5002,$5175,$5C5B,$5E77,
	$661E,$663A,$67C4,$68C5,$70B3,$7501,$75C5,$79C9,$7ADD,$8F27,$9920,$9A08,$4FDD,$5821,$5831,$5BF6,
	$666E,$6B65,$6D11,$6E7A,$6F7D,$73E4,$752B,$83E9,$88DC,$8913,$8B5C,$8F14,$4F0F,$50D5,$5310,$535C,
	$5B93,$5FA9,$670D,$798F,$8179,$832F,$8514,$8907,$8986,$8F39,$8F3B,$99A5,$9C12,$672C,$4E76,$4FF8,
	$5949,$5C01,$5CEF,$5CF0,$6367,$68D2,$70FD,$71A2,$742B,$7E2B,$84EC,$8702,$9022,$92D2,$9CF3,$4E0D,
	$4ED8,$4FEF,$5085,$5256,$526F,$5426,$5490,$57E0,$592B,$5A66,$5B5A,$5B75,$5BCC,$5E9C,$F966,$6276,
	$6577,$65A7,$6D6E,$6EA5,$7236,$7B26,$7C3F,$7F36,$8150,$8151,$819A,$8240,$8299,$83A9,$8A03,$8CA0,
	$8CE6,$8CFB,$8D74,$8DBA,$90E8,$91DC,$961C,$9644,$99D9,$9CE7,$5317,$5206,$5429,$5674,$58B3,$5954,
	$596E,$5FFF,$61A4,$626E,$6610,$6C7E,$711A,$76C6,$7C89,$7CDE,$7D1B,$82AC,$8CC1,$96F0,$F967,$4F5B,
	$5F17,$5F7F,$62C2,$5D29,$670B,$68DA,$787C,$7E43,$9D6C,$4E15,$5099,$5315,$532A,$5351,$5983,$5A62,
	$5E87,$60B2,$618A,$6249,$6279,$6590,$6787,$69A7,$6BD4,$6BD6,$6BD7,$6BD8,$6CB8,$F968,$7435,$75FA,
	$7812,$7891,$79D5,$79D8,$7C83,$7DCB,$7FE1,$80A5,$813E,$81C2,$83F2,$871A,$88E8,$8AB9,$8B6C,$8CBB,
	$9119,$975E,$98DB,$9F3B,$56AC,$5B2A,$5F6C,$658C,$6AB3,$6BAF,$6D5C,$6FF1,$7015,$725D,$73AD,$8CA7,
	$8CD3,$983B,$6191,$6C37,$8058,$9A01,$4E4D,$4E8B,$4E9B,$4ED5,$4F3A,$4F3C,$4F7F,$4FDF,$50FF,$53F2,
	$53F8,$5506,$55E3,$56DB,$58EB,$5962,$5A11,$5BEB,$5BFA,$5C04,$5DF3,$5E2B,$5F99,$601D,$6368,$659C,
	$65AF,$67F6,$67FB,$68AD,$6B7B,$6C99,$6CD7,$6E23,$7009,$7345,$7802,$793E,$7940,$7960,$79C1,$7BE9,
	$7D17,$7D72,$8086,$820D,$838E,$84D1,$86C7,$88DF,$8A50,$8A5E,$8B1D,$8CDC,$8D66,$8FAD,$90AA,$98FC,
	$99DF,$9E9D,$524A,$F969,$6714,$F96A,$5098,$522A,$5C71,$6563,$6C55,$73CA,$7523,$759D,$7B97,$849C,
	$9178,$9730,$4E77,$6492,$6BBA,$715E,$85A9,$4E09,$F96B,$6749,$68EE,$6E17,$829F,$8518,$886B,$63F7,
	$6F81,$9212,$98AF,$4E0A,$50B7,$50CF,$511F,$5546,$55AA,$5617,$5B40,$5C19,$5CE0,$5E38,$5E8A,$5EA0,
	$5EC2,$60F3,$6851,$6A61,$6E58,$723D,$7240,$72C0,$76F8,$7965,$7BB1,$7FD4,$88F3,$89F4,$8A73,$8C61,
	$8CDE,$971C,$585E,$74BD,$8CFD,$55C7,$F96C,$7A61,$7D22,$8272,$7272,$751F,$7525,$F96D,$7B19,$5885,
	$58FB,$5DBC,$5E8F,$5EB6,$5F90,$6055,$6292,$637F,$654D,$6691,$66D9,$66F8,$6816,$68F2,$7280,$745E,
	$7B6E,$7D6E,$7DD6,$7F72,$80E5,$8212,$85AF,$897F,$8A93,$901D,$92E4,$9ECD,$9F20,$5915,$596D,$5E2D,
	$60DC,$6614,$6673,$6790,$6C50,$6DC5,$6F5F,$77F3,$78A9,$84C6,$91CB,$932B,$4ED9,$50CA,$5148,$5584,
	$5B0B,$5BA3,$6247,$657E,$65CB,$6E32,$717D,$7401,$7444,$7487,$74BF,$766C,$79AA,$7DDA,$7E55,$7FA8,
	$817A,$81B3,$8239,$861A,$87EC,$8A75,$8DE3,$9078,$9291,$9425,$994D,$9BAE,$5368,$5C51,$6954,$6CC4,
	$6D29,$6E2B,$820C,$859B,$893B,$8A2D,$8AAA,$96EA,$9F67,$5261,$66B9,$6BB2,$7E96,$87FE,$8D0D,$9583,
	$965D,$651D,$6D89,$71EE,$F96E,$57CE,$59D3,$5BAC,$6027,$60FA,$6210,$661F,$665F,$7329,$73F9,$76DB,
	$7701,$7B6C,$8056,$8072,$8165,$8AA0,$9192,$4E16,$52E2,$6B72,$6D17,$7A05,$7B39,$7D30,$F96F,$8CB0,
	$53EC,$562F,$5851,$5BB5,$5C0F,$5C11,$5DE2,$6240,$6383,$6414,$662D,$68B3,$6CBC,$6D88,$6EAF,$701F,
	$70A4,$71D2,$7526,$758F,$758E,$7619,$7B11,$7BE0,$7C2B,$7D20,$7D39,$852C,$856D,$8607,$8A34,$900D,
	$9061,$90B5,$92B7,$97F6,$9A37,$4FD7,$5C6C,$675F,$6D91,$7C9F,$7E8C,$8B16,$8D16,$901F,$5B6B,$5DFD,
	$640D,$84C0,$905C,$98E1,$7387,$5B8B,$609A,$677E,$6DDE,$8A1F,$8AA6,$9001,$980C,$5237,$F970,$7051,
	$788E,$9396,$8870,$91D7,$4FEE,$53D7,$55FD,$56DA,$5782,$58FD,$5AC2,$5B88,$5CAB,$5CC0,$5E25,$6101,
	$620D,$624B,$6388,$641C,$6536,$6578,$6A39,$6B8A,$6C34,$6D19,$6F31,$71E7,$72E9,$7378,$7407,$74B2,
	$7626,$7761,$79C0,$7A57,$7AEA,$7CB9,$7D8F,$7DAC,$7E61,$7F9E,$8129,$8331,$8490,$84DA,$85EA,$8896,
	$8AB0,$8B90,$8F38,$9042,$9083,$916C,$9296,$92B9,$968B,$96A7,$96A8,$96D6,$9700,$9808,$9996,$9AD3,
	$9B1A,$53D4,$587E,$5919,$5B70,$5BBF,$6DD1,$6F5A,$719F,$7421,$74B9,$8085,$83FD,$5DE1,$5F87,$5FAA,
	$6042,$65EC,$6812,$696F,$6A53,$6B89,$6D35,$6DF3,$73E3,$76FE,$77AC,$7B4D,$7D14,$8123,$821C,$8340,
	$84F4,$8563,$8A62,$8AC4,$9187,$931E,$9806,$99B4,$620C,$8853,$8FF0,$9265,$5D07,$5D27,$5D69,$745F,
	$819D,$8768,$6FD5,$62FE,$7FD2,$8936,$8972,$4E1E,$4E58,$50E7,$52DD,$5347,$627F,$6607,$7E69,$8805,
	$965E,$4F8D,$5319,$5636,$59CB,$5AA4,$5C38,$5C4E,$5C4D,$5E02,$5F11,$6043,$65BD,$662F,$6642,$67BE,
	$67F4,$731C,$77E2,$793A,$7FC5,$8494,$84CD,$8996,$8A66,$8A69,$8AE1,$8C55,$8C7A,$57F4,$5BD4,$5F0F,
	$606F,$62ED,$690D,$6B96,$6E5C,$7184,$7BD2,$8755,$8B58,$8EFE,$98DF,$98FE,$4F38,$4F81,$4FE1,$547B,
	$5A20,$5BB8,$613C,$65B0,$6668,$71FC,$7533,$795E,$7D33,$814E,$81E3,$8398,$85AA,$85CE,$8703,$8A0A,
	$8EAB,$8F9B,$F971,$8FC5,$5931,$5BA4,$5BE6,$6089,$5BE9,$5C0B,$5FC3,$6C81,$F972,$6DF1,$700B,$751A,
	$82AF,$8AF6,$4EC0,$5341,$F973,$96D9,$6C0F,$4E9E,$4FC4,$5152,$555E,$5A25,$5CE8,$6211,$7259,$82BD,
	$83AA,$86FE,$8859,$8A1D,$963F,$96C5,$9913,$9D09,$9D5D,$580A,$5CB3,$5DBD,$5E44,$60E1,$6115,$63E1,
	$6A02,$6E25,$9102,$9354,$984E,$9C10,$9F77,$5B89,$5CB8,$6309,$664F,$6848,$773C,$96C1,$978D,$9854,
	$9B9F,$65A1,$8B01,$8ECB,$95BC,$5535,$5CA9,$5DD6,$5EB5,$6697,$764C,$83F4,$95C7,$58D3,$62BC,$72CE,
	$9D28,$4EF0,$592E,$600F,$663B,$6B83,$79E7,$9D26,$5393,$54C0,$57C3,$5D16,$611B,$66D6,$6DAF,$788D,
	$827E,$9698,$9744,$5384,$627C,$6396,$6DB2,$7E0A,$814B,$984D,$6AFB,$7F4C,$9DAF,$9E1A,$4E5F,$503B,
	$51B6,$591C,$60F9,$63F6,$6930,$723A,$8036,$F974,$91CE,$5F31,$F975,$F976,$7D04,$82E5,$846F,$84BB,
	$85E5,$8E8D,$F977,$4F6F,$F978,$F979,$58E4,$5B43,$6059,$63DA,$6518,$656D,$6698,$F97A,$694A,$6A23,
	$6D0B,$7001,$716C,$75D2,$760D,$79B3,$7A70,$F97B,$7F8A,$F97C,$8944,$F97D,$8B93,$91C0,$967D,$F97E,
	$990A,$5704,$5FA1,$65BC,$6F01,$7600,$79A6,$8A9E,$99AD,$9B5A,$9F6C,$5104,$61B6,$6291,$6A8D,$81C6,
	$5043,$5830,$5F66,$7109,$8A00,$8AFA,$5B7C,$8616,$4FFA,$513C,$56B4,$5944,$63A9,$6DF9,$5DAA,$696D,
	$5186,$4E88,$4F59,$F97F,$F980,$F981,$5982,$F982,$F983,$6B5F,$6C5D,$F984,$74B5,$7916,$F985,$8207,
	$8245,$8339,$8F3F,$8F5D,$F986,$9918,$F987,$F988,$F989,$4EA6,$F98A,$57DF,$5F79,$6613,$F98B,$F98C,
	$75AB,$7E79,$8B6F,$F98D,$9006,$9A5B,$56A5,$5827,$59F8,$5A1F,$5BB4,$F98E,$5EF6,$F98F,$F990,$6350,
	$633B,$F991,$693D,$6C87,$6CBF,$6D8E,$6D93,$6DF5,$6F14,$F992,$70DF,$7136,$7159,$F993,$71C3,$71D5,
	$F994,$784F,$786F,$F995,$7B75,$7DE3,$F996,$7E2F,$F997,$884D,$8EDF,$F998,$F999,$F99A,$925B,$F99B,
	$9CF6,$F99C,$F99D,$F99E,$6085,$6D85,$F99F,$71B1,$F9A0,$F9A1,$95B1,$53AD,$F9A2,$F9A3,$F9A4,$67D3,
	$F9A5,$708E,$7130,$7430,$8276,$82D2,$F9A6,$95BB,$9AE5,$9E7D,$66C4,$F9A7,$71C1,$8449,$F9A8,$F9A9,
	$584B,$F9AA,$F9AB,$5DB8,$5F71,$F9AC,$6620,$668E,$6979,$69AE,$6C38,$6CF3,$6E36,$6F41,$6FDA,$701B,
	$702F,$7150,$71DF,$7370,$F9AD,$745B,$F9AE,$74D4,$76C8,$7A4E,$7E93,$F9AF,$F9B0,$82F1,$8A60,$8FCE,
	$F9B1,$9348,$F9B2,$9719,$F9B3,$F9B4,$4E42,$502A,$F9B5,$5208,$53E1,$66F3,$6C6D,$6FCA,$730A,$777F,
	$7A62,$82AE,$85DD,$8602,$F9B6,$88D4,$8A63,$8B7D,$8C6B,$F9B7,$92B3,$F9B8,$9713,$9810,$4E94,$4F0D,
	$4FC9,$50B2,$5348,$543E,$5433,$55DA,$5862,$58BA,$5967,$5A1B,$5BE4,$609F,$F9B9,$61CA,$6556,$65FF,
	$6664,$68A7,$6C5A,$6FB3,$70CF,$71AC,$7352,$7B7D,$8708,$8AA4,$9C32,$9F07,$5C4B,$6C83,$7344,$7389,
	$923A,$6EAB,$7465,$761F,$7A69,$7E15,$860A,$5140,$58C5,$64C1,$74EE,$7515,$7670,$7FC1,$9095,$96CD,
	$9954,$6E26,$74E6,$7AA9,$7AAA,$81E5,$86D9,$8778,$8A1B,$5A49,$5B8C,$5B9B,$68A1,$6900,$6D63,$73A9,
	$7413,$742C,$7897,$7DE9,$7FEB,$8118,$8155,$839E,$8C4C,$962E,$9811,$66F0,$5F80,$65FA,$6789,$6C6A,
	$738B,$502D,$5A03,$6B6A,$77EE,$5916,$5D6C,$5DCD,$7325,$754F,$F9BA,$F9BB,$50E5,$51F9,$582F,$592D,
	$5996,$59DA,$5BE5,$F9BC,$F9BD,$5DA2,$62D7,$6416,$6493,$64FE,$F9BE,$66DC,$F9BF,$6A48,$F9C0,$71FF,
	$7464,$F9C1,$7A88,$7AAF,$7E47,$7E5E,$8000,$8170,$F9C2,$87EF,$8981,$8B20,$9059,$F9C3,$9080,$9952,
	$617E,$6B32,$6D74,$7E1F,$8925,$8FB1,$4FD1,$50AD,$5197,$52C7,$57C7,$5889,$5BB9,$5EB8,$6142,$6995,
	$6D8C,$6E67,$6EB6,$7194,$7462,$7528,$752C,$8073,$8338,$84C9,$8E0A,$9394,$93DE,$F9C4,$4E8E,$4F51,
	$5076,$512A,$53C8,$53CB,$53F3,$5B87,$5BD3,$5C24,$611A,$6182,$65F4,$725B,$7397,$7440,$76C2,$7950,
	$7991,$79B9,$7D06,$7FBD,$828B,$85D5,$865E,$8FC2,$9047,$90F5,$91EA,$9685,$96E8,$96E9,$52D6,$5F67,
	$65ED,$6631,$682F,$715C,$7A36,$90C1,$980A,$4E91,$F9C5,$6A52,$6B9E,$6F90,$7189,$8018,$82B8,$8553,
	$904B,$9695,$96F2,$97FB,$851A,$9B31,$4E90,$718A,$96C4,$5143,$539F,$54E1,$5713,$5712,$57A3,$5A9B,
	$5AC4,$5BC3,$6028,$613F,$63F4,$6C85,$6D39,$6E72,$6E90,$7230,$733F,$7457,$82D1,$8881,$8F45,$9060,
	$F9C6,$9662,$9858,$9D1B,$6708,$8D8A,$925E,$4F4D,$5049,$50DE,$5371,$570D,$59D4,$5A01,$5C09,$6170,
	$6690,$6E2D,$7232,$744B,$7DEF,$80C3,$840E,$8466,$853F,$875F,$885B,$8918,$8B02,$9055,$97CB,$9B4F,
	$4E73,$4F91,$5112,$516A,$F9C7,$552F,$55A9,$5B7A,$5BA5,$5E7C,$5E7D,$5EBE,$60A0,$60DF,$6108,$6109,
	$63C4,$6538,$6709,$F9C8,$67D4,$67DA,$F9C9,$6961,$6962,$6CB9,$6D27,$F9CA,$6E38,$F9CB,$6FE1,$7336,
	$7337,$F9CC,$745C,$7531,$F9CD,$7652,$F9CE,$F9CF,$7DAD,$81FE,$8438,$88D5,$8A98,$8ADB,$8AED,$8E30,
	$8E42,$904A,$903E,$907A,$9149,$91C9,$936E,$F9D0,$F9D1,$5809,$F9D2,$6BD3,$8089,$80B2,$F9D3,$F9D4,
	$5141,$596B,$5C39,$F9D5,$F9D6,$6F64,$73A7,$80E4,$8D07,$F9D7,$9217,$958F,$F9D8,$F9D9,$F9DA,$F9DB,
	$807F,$620E,$701C,$7D68,$878D,$F9DC,$57A0,$6069,$6147,$6BB7,$8ABE,$9280,$96B1,$4E59,$541F,$6DEB,
	$852D,$9670,$97F3,$98EE,$63D6,$6CE3,$9091,$51DD,$61C9,$81BA,$9DF9,$4F9D,$501A,$5100,$5B9C,$610F,
	$61FF,$64EC,$6905,$6BC5,$7591,$77E3,$7FA9,$8264,$858F,$87FB,$8863,$8ABC,$8B70,$91AB,$4E8C,$4EE5,
	$4F0A,$F9DD,$F9DE,$5937,$59E8,$F9DF,$5DF2,$5F1B,$5F5B,$6021,$F9E0,$F9E1,$F9E2,$F9E3,$723E,$73E5,
	$F9E4,$7570,$75CD,$F9E5,$79FB,$F9E6,$800C,$8033,$8084,$82E1,$8351,$F9E7,$F9E8,$8CBD,$8CB3,$9087,
	$F9E9,$F9EA,$98F4,$990C,$F9EB,$F9EC,$7037,$76CA,$7FCA,$7FCC,$7FFC,$8B1A,$4EBA,$4EC1,$5203,$5370,
	$F9ED,$54BD,$56E0,$59FB,$5BC5,$5F15,$5FCD,$6E6E,$F9EE,$F9EF,$7D6A,$8335,$F9F0,$8693,$8A8D,$F9F1,
	$976D,$9777,$F9F2,$F9F3,$4E00,$4F5A,$4F7E,$58F9,$65E5,$6EA2,$9038,$93B0,$99B9,$4EFB,$58EC,$598A,
	$59D9,$6041,$F9F4,$F9F5,$7A14,$F9F6,$834F,$8CC3,$5165,$5344,$F9F7,$F9F8,$F9F9,$4ECD,$5269,$5B55,
	$82BF,$4ED4,$523A,$54A8,$59C9,$59FF,$5B50,$5B57,$5B5C,$6063,$6148,$6ECB,$7099,$716E,$7386,$74F7,
	$75B5,$78C1,$7D2B,$8005,$81EA,$8328,$8517,$85C9,$8AEE,$8CC7,$96CC,$4F5C,$52FA,$56BC,$65AB,$6628,
	$707C,$70B8,$7235,$7DBD,$828D,$914C,$96C0,$9D72,$5B71,$68E7,$6B98,$6F7A,$76DE,$5C91,$66AB,$6F5B,
	$7BB4,$7C2A,$8836,$96DC,$4E08,$4ED7,$5320,$5834,$58BB,$58EF,$596C,$5C07,$5E33,$5E84,$5F35,$638C,
	$66B2,$6756,$6A1F,$6AA3,$6B0C,$6F3F,$7246,$F9FA,$7350,$748B,$7AE0,$7CA7,$8178,$81DF,$81E7,$838A,
	$846C,$8523,$8594,$85CF,$88DD,$8D13,$91AC,$9577,$969C,$518D,$54C9,$5728,$5BB0,$624D,$6750,$683D,
	$6893,$6E3D,$6ED3,$707D,$7E21,$88C1,$8CA1,$8F09,$9F4B,$9F4E,$722D,$7B8F,$8ACD,$931A,$4F47,$4F4E,
	$5132,$5480,$59D0,$5E95,$62B5,$6775,$696E,$6A17,$6CAE,$6E1A,$72D9,$732A,$75BD,$7BB8,$7D35,$82E7,
	$83F9,$8457,$85F7,$8A5B,$8CAF,$8E87,$9019,$90B8,$96CE,$9F5F,$52E3,$540A,$5AE1,$5BC2,$6458,$6575,
	$6EF4,$72C4,$F9FB,$7684,$7A4D,$7B1B,$7C4D,$7E3E,$7FDF,$837B,$8B2B,$8CCA,$8D64,$8DE1,$8E5F,$8FEA,
	$8FF9,$9069,$93D1,$4F43,$4F7A,$50B3,$5168,$5178,$524D,$526A,$5861,$587C,$5960,$5C08,$5C55,$5EDB,
	$609B,$6230,$6813,$6BBF,$6C08,$6FB1,$714E,$7420,$7530,$7538,$7551,$7672,$7B4C,$7B8B,$7BAD,$7BC6,
	$7E8F,$8A6E,$8F3E,$8F49,$923F,$9293,$9322,$942B,$96FB,$985A,$986B,$991E,$5207,$622A,$6298,$6D59,
	$7664,$7ACA,$7BC0,$7D76,$5360,$5CBE,$5E97,$6F38,$70B9,$7C98,$9711,$9B8E,$9EDE,$63A5,$647A,$8776,
	$4E01,$4E95,$4EAD,$505C,$5075,$5448,$59C3,$5B9A,$5E40,$5EAD,$5EF7,$5F81,$60C5,$633A,$653F,$6574,
	$65CC,$6676,$6678,$67FE,$6968,$6A89,$6B63,$6C40,$6DC0,$6DE8,$6E1F,$6E5E,$701E,$70A1,$738E,$73FD,
	$753A,$775B,$7887,$798E,$7A0B,$7A7D,$7CBE,$7D8E,$8247,$8A02,$8AEA,$8C9E,$912D,$914A,$91D8,$9266,
	$92CC,$9320,$9706,$9756,$975C,$9802,$9F0E,$5236,$5291,$557C,$5824,$5E1D,$5F1F,$608C,$63D0,$68AF,
	$6FDF,$796D,$7B2C,$81CD,$85BA,$88FD,$8AF8,$8E44,$918D,$9664,$969B,$973D,$984C,$9F4A,$4FCE,$5146,
	$51CB,$52A9,$5632,$5F14,$5F6B,$63AA,$64CD,$65E9,$6641,$66FA,$66F9,$671D,$689D,$68D7,$69FD,$6F15,
	$6F6E,$7167,$71E5,$722A,$74AA,$773A,$7956,$795A,$79DF,$7A20,$7A95,$7C97,$7CDF,$7D44,$7E70,$8087,
	$85FB,$86A4,$8A54,$8ABF,$8D99,$8E81,$9020,$906D,$91E3,$963B,$96D5,$9CE5,$65CF,$7C07,$8DB3,$93C3,
	$5B58,$5C0A,$5352,$62D9,$731D,$5027,$5B97,$5F9E,$60B0,$616B,$68D5,$6DD9,$742E,$7A2E,$7D42,$7D9C,
	$7E31,$816B,$8E2A,$8E35,$937E,$9418,$4F50,$5750,$5DE6,$5EA7,$632B,$7F6A,$4E3B,$4F4F,$4F8F,$505A,
	$59DD,$80C4,$546A,$5468,$55FE,$594F,$5B99,$5DDE,$5EDA,$665D,$6731,$67F1,$682A,$6CE8,$6D32,$6E4A,
	$6F8D,$70B7,$73E0,$7587,$7C4C,$7D02,$7D2C,$7DA2,$821F,$86DB,$8A3B,$8A85,$8D70,$8E8A,$8F33,$9031,
	$914E,$9152,$9444,$99D0,$7AF9,$7CA5,$4FCA,$5101,$51C6,$57C8,$5BEF,$5CFB,$6659,$6A3D,$6D5A,$6E96,
	$6FEC,$710C,$756F,$7AE3,$8822,$9021,$9075,$96CB,$99FF,$8301,$4E2D,$4EF2,$8846,$91CD,$537D,$6ADB,
	$696B,$6C41,$847A,$589E,$618E,$66FE,$62EF,$70DD,$7511,$75C7,$7E52,$84B8,$8B49,$8D08,$4E4B,$53EA,
	$54AB,$5730,$5740,$5FD7,$6301,$6307,$646F,$652F,$65E8,$667A,$679D,$67B3,$6B62,$6C60,$6C9A,$6F2C,
	$77E5,$7825,$7949,$7957,$7D19,$80A2,$8102,$81F3,$829D,$82B7,$8718,$8A8C,$F9FC,$8D04,$8DBE,$9072,
	$76F4,$7A19,$7A37,$7E54,$8077,$5507,$55D4,$5875,$632F,$6422,$6649,$664B,$686D,$699B,$6B84,$6D25,
	$6EB1,$73CD,$7468,$74A1,$755B,$75B9,$76E1,$771E,$778B,$79E6,$7E09,$7E1D,$81FB,$852F,$8897,$8A3A,
	$8CD1,$8EEB,$8FB0,$9032,$93AD,$9663,$9673,$9707,$4F84,$53F1,$59EA,$5AC9,$5E19,$684E,$74C6,$75BE,
	$79E9,$7A92,$81A3,$86ED,$8CEA,$8DCC,$8FED,$659F,$6715,$F9FD,$57F7,$6F57,$7DDD,$8F2F,$93F6,$96C6,
	$5FB5,$61F2,$6F84,$4E14,$4F98,$501F,$53C9,$55DF,$5D6F,$5DEE,$6B21,$6B64,$78CB,$7B9A,$F9FE,$8E49,
	$8ECA,$906E,$6349,$643E,$7740,$7A84,$932F,$947F,$9F6A,$64B0,$6FAF,$71E6,$74A8,$74DA,$7AC4,$7C12,
	$7E82,$7CB2,$7E98,$8B9A,$8D0A,$947D,$9910,$994C,$5239,$5BDF,$64E6,$672D,$7D2E,$50ED,$53C3,$5879,
	$6158,$6159,$61FA,$65AC,$7AD9,$8B92,$8B96,$5009,$5021,$5275,$5531,$5A3C,$5EE0,$5F70,$6134,$655E,
	$660C,$6636,$66A2,$69CD,$6EC4,$6F32,$7316,$7621,$7A93,$8139,$8259,$83D6,$84BC,$50B5,$57F0,$5BC0,
	$5BE8,$5F69,$63A1,$7826,$7DB5,$83DC,$8521,$91C7,$91F5,$518A,$67F5,$7B56,$8CAC,$51C4,$59BB,$60BD,
	$8655,$501C,$F9FF,$5254,$5C3A,$617D,$621A,$62D3,$64F2,$65A5,$6ECC,$7620,$810A,$8E60,$965F,$96BB,
	$4EDF,$5343,$5598,$5929,$5DDD,$64C5,$6CC9,$6DFA,$7394,$7A7F,$821B,$85A6,$8CE4,$8E10,$9077,$91E7,
	$95E1,$9621,$97C6,$51F8,$54F2,$5586,$5FB9,$64A4,$6F88,$7DB4,$8F1F,$8F4D,$9435,$50C9,$5C16,$6CBE,
	$6DFB,$751B,$77BB,$7C3D,$7C64,$8A79,$8AC2,$581E,$59BE,$5E16,$6377,$7252,$758A,$776B,$8ADC,$8CBC,
	$8F12,$5EF3,$6674,$6DF8,$807D,$83C1,$8ACB,$9751,$9BD6,$FA00,$5243,$66FF,$6D95,$6EEF,$7DE0,$8AE6,
	$902E,$905E,$9AD4,$521D,$527F,$54E8,$6194,$6284,$62DB,$68A2,$6912,$695A,$6A35,$7092,$7126,$785D,
	$7901,$790E,$79D2,$7A0D,$8096,$8278,$82D5,$8349,$8549,$8C82,$8D85,$9162,$918B,$91AE,$4FC3,$56D1,
	$71ED,$77D7,$8700,$89F8,$5BF8,$5FD6,$6751,$90A8,$53E2,$585A,$5BF5,$60A4,$6181,$6460,$7E3D,$8070,
	$8525,$9283,$64AE,$50AC,$5D14,$6700,$589C,$62BD,$63A8,$690E,$6978,$6A1E,$6E6B,$76BA,$79CB,$82BB,
	$8429,$8ACF,$8DA8,$8FFD,$9112,$914B,$919C,$9310,$9318,$939A,$96DB,$9A36,$9C0D,$4E11,$755C,$795D,
	$7AFA,$7B51,$7BC9,$7E2E,$84C4,$8E59,$8E74,$8EF8,$9010,$6625,$693F,$7443,$51FA,$672E,$9EDC,$5145,
	$5FE0,$6C96,$87F2,$885D,$8877,$60B4,$81B5,$8403,$8D05,$53D6,$5439,$5634,$5A36,$5C31,$708A,$7FE0,
	$805A,$8106,$81ED,$8DA3,$9189,$9A5F,$9DF2,$5074,$4EC4,$53A0,$60FB,$6E2C,$5C64,$4F88,$5024,$55E4,
	$5CD9,$5E5F,$6065,$6894,$6CBB,$6DC4,$71BE,$75D4,$75F4,$7661,$7A1A,$7A49,$7DC7,$7DFB,$7F6E,$81F4,
	$86A9,$8F1C,$96C9,$99B3,$9F52,$5247,$52C5,$98ED,$89AA,$4E03,$67D2,$6F06,$4FB5,$5BE2,$6795,$6C88,
	$6D78,$741B,$7827,$91DD,$937C,$87C4,$79E4,$7A31,$5FEB,$4ED6,$54A4,$553E,$58AE,$59A5,$60F0,$6253,
	$62D6,$6736,$6955,$8235,$9640,$99B1,$99DD,$502C,$5353,$5544,$577C,$FA01,$6258,$FA02,$64E2,$666B,
	$67DD,$6FC1,$6FEF,$7422,$7438,$8A17,$9438,$5451,$5606,$5766,$5F48,$619A,$6B4E,$7058,$70AD,$7DBB,
	$8A95,$596A,$812B,$63A2,$7708,$803D,$8CAA,$5854,$642D,$69BB,$5B95,$5E11,$6E6F,$FA03,$8569,$514C,
	$53F0,$592A,$6020,$614B,$6B86,$6C70,$6CF0,$7B1E,$80CE,$82D4,$8DC6,$90B0,$98B1,$FA04,$64C7,$6FA4,
	$6491,$6504,$514E,$5410,$571F,$8A0E,$615F,$6876,$FA05,$75DB,$7B52,$7D71,$901A,$5806,$69CC,$817F,
	$892A,$9000,$9839,$5078,$5957,$59AC,$6295,$900F,$9B2A,$615D,$7279,$95D6,$5761,$5A46,$5DF4,$628A,
	$64AD,$64FA,$6777,$6CE2,$6D3E,$722C,$7436,$7834,$7F77,$82AD,$8DDB,$9817,$5224,$5742,$677F,$7248,
	$74E3,$8CA9,$8FA6,$9211,$962A,$516B,$53ED,$634C,$4F69,$5504,$6096,$6557,$6C9B,$6D7F,$724C,$72FD,
	$7A17,$8987,$8C9D,$5F6D,$6F8E,$70F9,$81A8,$610E,$4FBF,$504F,$6241,$7247,$7BC7,$7DE8,$7FE9,$904D,
	$97AD,$9A19,$8CB6,$576A,$5E73,$67B0,$840D,$8A55,$5420,$5B16,$5E63,$5EE2,$5F0A,$6583,$80BA,$853D,
	$9589,$965B,$4F48,$5305,$530D,$530F,$5486,$54FA,$5703,$5E03,$6016,$629B,$62B1,$6355,$FA06,$6CE1,
	$6D66,$75B1,$7832,$80DE,$812F,$82DE,$8461,$84B2,$888D,$8912,$900B,$92EA,$98FD,$9B91,$5E45,$66B4,
	$66DD,$7011,$7206,$FA07,$4FF5,$527D,$5F6A,$6153,$6753,$6A19,$6F02,$74E2,$7968,$8868,$8C79,$98C7,
	$98C4,$9A43,$54C1,$7A1F,$6953,$8AF7,$8C4A,$98A8,$99AE,$5F7C,$62AB,$75B2,$76AE,$88AB,$907F,$9642,
	$5339,$5F3C,$5FC5,$6CCC,$73CC,$7562,$758B,$7B46,$82FE,$999D,$4E4F,$903C,$4E0B,$4F55,$53A6,$590F,
	$5EC8,$6630,$6CB3,$7455,$8377,$8766,$8CC0,$9050,$971E,$9C15,$58D1,$5B78,$8650,$8B14,$9DB4,$5BD2,
	$6068,$608D,$65F1,$6C57,$6F22,$6FA3,$701A,$7F55,$7FF0,$9591,$9592,$9650,$97D3,$5272,$8F44,$51FD,
	$542B,$54B8,$5563,$558A,$6ABB,$6DB5,$7DD8,$8266,$929C,$9677,$9E79,$5408,$54C8,$76D2,$86E4,$95A4,
	$95D4,$965C,$4EA2,$4F09,$59EE,$5AE6,$5DF7,$6052,$6297,$676D,$6841,$6C86,$6E2F,$7F38,$809B,$822A,
	$FA08,$FA09,$9805,$4EA5,$5055,$54B3,$5793,$595A,$5B69,$5BB3,$61C8,$6977,$6D77,$7023,$87F9,$89E3,
	$8A72,$8AE7,$9082,$99ED,$9AB8,$52BE,$6838,$5016,$5E78,$674F,$8347,$884C,$4EAB,$5411,$56AE,$73E6,
	$9115,$97FF,$9909,$9957,$9999,$5653,$589F,$865B,$8A31,$61B2,$6AF6,$737B,$8ED2,$6B47,$96AA,$9A57,
	$5955,$7200,$8D6B,$9769,$4FD4,$5CF4,$5F26,$61F8,$665B,$6CEB,$70AB,$7384,$73B9,$73FE,$7729,$774D,
	$7D43,$7D62,$7E23,$8237,$8852,$FA0A,$8CE2,$9249,$986F,$5B51,$7A74,$8840,$9801,$5ACC,$4FE0,$5354,
	$593E,$5CFD,$633E,$6D79,$72F9,$8105,$8107,$83A2,$92CF,$9830,$4EA8,$5144,$5211,$578B,$5F62,$6CC2,
	$6ECE,$7005,$7050,$70AF,$7192,$73E9,$7469,$834A,$87A2,$8861,$9008,$90A2,$93A3,$99A8,$516E,$5F57,
	$60E0,$6167,$66B3,$8559,$8E4A,$91AF,$978B,$4E4E,$4E92,$547C,$58D5,$58FA,$597D,$5CB5,$5F27,$6236,
	$6248,$660A,$6667,$6BEB,$6D69,$6DCF,$6E56,$6EF8,$6F94,$6FE0,$6FE9,$705D,$72D0,$7425,$745A,$74E0,
	$7693,$795C,$7CCA,$7E1E,$80E1,$82A6,$846B,$84BF,$864E,$865F,$8774,$8B77,$8C6A,$93AC,$9800,$9865,
	$60D1,$6216,$9177,$5A5A,$660F,$6DF7,$6E3E,$743F,$9B42,$5FFD,$60DA,$7B0F,$54C4,$5F18,$6C5E,$6CD3,
	$6D2A,$70D8,$7D05,$8679,$8A0C,$9D3B,$5316,$548C,$5B05,$6A3A,$706B,$7575,$798D,$79BE,$82B1,$83EF,
	$8A71,$8B41,$8CA8,$9774,$FA0B,$64F4,$652B,$78BA,$78BB,$7A6B,$4E38,$559A,$5950,$5BA6,$5E7B,$60A3,
	$63DB,$6B61,$6665,$6853,$6E19,$7165,$74B0,$7D08,$9084,$9A69,$9C25,$6D3B,$6ED1,$733E,$8C41,$95CA,
	$51F0,$5E4C,$5FA8,$604D,$60F6,$6130,$614C,$6643,$6644,$69A5,$6CC1,$6E5F,$6EC9,$6F62,$714C,$749C,
	$7687,$7BC1,$7C27,$8352,$8757,$9051,$968D,$9EC3,$532F,$56DE,$5EFB,$5F8A,$6062,$6094,$61F7,$6666,
	$6703,$6A9C,$6DEE,$6FAE,$7070,$736A,$7E6A,$81BE,$8334,$86D4,$8AA8,$8CC4,$5283,$7372,$5B96,$6A6B,
	$9404,$54EE,$5686,$5B5D,$6548,$6585,$66C9,$689F,$6D8D,$6DC6,$723B,$80B4,$9175,$9A4D,$4FAF,$5019,
	$539A,$540E,$543C,$5589,$55C5,$5E3F,$5F8C,$673D,$7166,$73DD,$9005,$52DB,$52F3,$5864,$58CE,$7104,
	$718F,$71FB,$85B0,$8A13,$6688,$85A8,$55A7,$6684,$714A,$8431,$5349,$5599,$6BC1,$5F59,$5FBD,$63EE,
	$6689,$7147,$8AF1,$8F1D,$9EBE,$4F11,$643A,$70CB,$7566,$8667,$6064,$8B4E,$9DF8,$5147,$51F6,$5308,
	$6D36,$80F8,$9ED1,$6615,$6B23,$7098,$75D5,$5403,$5C79,$7D07,$8A16,$6B20,$6B3D,$6B46,$5438,$6070,
	$6D3D,$7FD5,$8208,$50D6,$51DE,$559C,$566B,$56CD,$59EC,$5B09,$5E0C,$6199,$6198,$6231,$665E,$66E6,
	$7199,$71B9,$71BA,$72A7,$79A7,$7A00,$7FB2,$8A70
	);

        table_340234a6:array[0..164] of word=(
        $3001,$3002,$2024,$2025,$2026,$0308,$3003,$2010,$2015,$2016,$FF3C,$FF5E,$02BB,$02BC,$201C,$201D,
        $3014,$3015,$3008,$3009,$300A,$300B,$300C,$300D,$300E,$300F,$3010,$3011,$00B1,$00D7,$00F7,$2260,
        $2264,$2265,$221E,$2234,$02DA,$2032,$2033,$2103,$212B,$FFE0,$FFE1,$FFE5,$2642,$2640,$2220,$22A5,
        $2312,$2202,$2207,$2261,$2252,$00A7,$203B,$2606,$2605,$25CB,$25CF,$25CE,$25C7,$25C6,$25A1,$25A0,
        $25B3,$25B2,$25BD,$25BC,$2192,$2190,$2191,$2193,$2194,$3013,$226A,$226B,$221A,$223D,$221D,$2235,
        $222B,$222C,$2208,$220B,$2286,$2287,$2282,$2283,$222A,$2229,$2227,$2228,$FFE2,$3000,$3000,$21D2,
        $21D4,$2200,$2203,$02CA,$02DC,$02C7,$02D8,$02DD,$02DA,$02D9,$00B8,$02DB,$00A1,$00BF,$02D0,$222E,
        $2211,$220F,$00A4,$2109,$2030,$25C1,$25C0,$25B7,$25B6,$2664,$2660,$2661,$2665,$2667,$2663,$25C9,
        $25C8,$25A3,$25D0,$25D1,$2592,$25A4,$25A5,$25A8,$25A7,$25A6,$25A9,$2668,$260F,$260E,$261C,$261E,
        $00B6,$2020,$2021,$2195,$2197,$2199,$2196,$2198,$266D,$2669,$266A,$266C,$327F,$321C,$2116,$33C7,
        $2122,$33C2,$33D8,$2121,$20AC
        );


function UNICODE2KSSM(code:word):word;
var
  first,second,third,kssm:integer;
begin
  Result:=code;
  if code<256 then
    exit;
  first:=(code-44032) div (21*28);
  second:=(code-44032) mod (21*28) div 28;
  third:=(code-44032) mod 28;
  kssm:=$8000;
  kssm:=kssm or (table_uni_cho[first] shl 10);
  kssm:=kssm or (table_uni_jung[second] shl 5);
  kssm:=kssm or (table_uni_jong[third]);

  Result:=kssm;
end;

// KSSM > UNICODE
function KSSM2UNICODE(code:word):word;
var
  cho,jung,jong,ucode:word;
begin
  Result:=code;
  if code<256 then
    exit;
  (* kssm
  h:=hi(code);
  l:=low(code);
  if ((h>=$e0) and (h<=$f9)) and
     (((l>=$31) and (l<=$7e)) or ((l>=$91) and (l<=$fe))) then
  begin
    // hanja
    ucode:=(h-$e0)*($7f-$31+$ff-$91);
    if l>=$91 then
      ucode:=ucode+($7f-$31)+l-$91
      else
        ucode:=ucode+l-$31;
    Result:=johabhanja[ucode];
  end else
  *)
  // hangul johab
  if code>=$8000 then
  begin
    cho:=(code shr 10) and $1f;
    jung:=(code shr 5) and $1f;
    jong:=code and $1f;
    ucode:=table_kssm_cho[cho] * 588 + table_kssm_jung[jung] * 28 + table_kssm_jong[jong] + 44032;
    Result:=ucode;
  end else
  if (code>=$3402) and (code<=$34a6) then
    Result:=table_340234a6[code-$3402]
  else
  // hanja 4888
  if (code>=$4000) and (code<=$5317) then
    Result:=johabhanja[code-$4000]
  else
  if (code>=$34C1) and (code<=$351e) then
    Result:=(code-$34c1)+$FF01
  else
  if (code>=$0400) and (code<=$0458) then
    Result:=(code-$0400)+$0250
  else
  if (code>=$0510) and (code<=$0566) then
    Result:=(code-$0510)+$0380
  else
  if ((code>=$1f01) and (code<=$1f53)) or
     ((code>=$1f61) and (code<=$1fb6)) then
    Result:=(code-$1f01)+$3041
  else
  if (code>=$2200) and (code<=$22f1) then
  begin
    Result:=code;
    if code=$2293 then
      Inc(Result)
      else if code=$2294 then
        Dec(Result);
  end else
  if (code>=$3521) and (code<=$357e) then
    Result:=(code-$3521)+$3131
  else
  if (code>=$3590) and (code<=$359b) then
    Result:=(code-$3590)+$2160
  else
  if (code>=$3581) and (code<=$358c) then
    Result:=(code-$3581)+$2170
  else
  if (code>=$35a1) and (code<=$35b8) then
  begin
    Result:=(code-$35a1)+$0391;
    if code>$35b1 then
      Inc(Result);
  end else
  if (code>=$35c1) and (code<=$35d8) then
  begin
    Result:=(code-$35c1)+$03b1;
    if code>$35d1 then
      Inc(Result);
  end else
  if (code>=$3647) and (code<=$3654) then
  begin
    Result:=(code-$3647)+$33a3;
    if code>$354a then
      Dec(Result,14);
  end else
  if (code>=$36b1) and (code<=$36f5) then
  begin
    Result:=(code-$36b1)+$3260;
    if code>$36cc then
      Dec(Result,3500)
      else
      if code>$36e6 then
        Dec(Result,3638)
  end else
  if (code>=$3711) and (code<=$372c) then
    Result:=(code-$3711)+$3200
  else
  if (code>=$372d) and (code<=$3746) then
    Result:=(code-$372d)+$249c
  else
  if (code>=$3747) and (code<=$3755) then
    Result:=(code-$3747)+$2474
  else
  if (code>=$37bb) and (code<=$37bf) then
    Result:=(code-$37bb)+$2483;
  if (code>=$32a1) and (code<=$32df) then
    Result:=(code-$32a1)+$FF61
  else
  if (code>=$3761) and (code<=$3781) then
  begin
    Result:=(code-$3761)+$0410;
    if code>$3766 then
      Dec(Result)
      else
      if code=$3767 then
        Result:=$0401;
  end
  else
  if (code>=$3791) and (code<=$37b1) then
  begin
    Result:=(code-$3791)+$0430;
    if code>$3796 then
      Dec(Result)
      else
      if code=$3797 then
        Result:=$0451;
  end;
end;

end.

