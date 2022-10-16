#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"                                              
#INCLUDE "fwschedule.ch"
#INCLUDE "CTBXLOG.CH"
    
STATIC __cIdCV8   	:= ""
STATIC __SubProc	:= ""
STATIC __BatchProc	:= ""
STATIC __lLogCTB			
STATIC __MvConOutR
STATIC __PEConOutR
STATIC aTxt	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBShowFLGบAutor  ณMarcos S. Lobo      บ Data ณ  01/28/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBShowFLG(cArqTRB)

Local aAreaTRB	:= GetArea()
Local aCampos	:= {}
Local aRotOri	:= aClone(aRotina)
Local oBrowse  	:= FWmBrowse():New()

PRIVATE aRotina   := {}

aRotina  := MenuDef()

If TableInDic("QL5") //Tratamento para relises < 12.1.17
	oBrowse:SetAlias("QL5")
	oBrowse:SetDescription(STR0028)	//"Log de Limpeza de Flags de Contabiliza็ใo	
	oBrowse:Activate()
Else
	If Aviso(STR0063,CRLF+STR0064+CRLF+CRLF+STR0065,{STR0066,STR0067},2)==1 //"Aten็ใo"###"Dicionแrio de dados desatualizado."###'A documenta็ใo para a cria็ใo da tabela "Log de Exclusใo de Flag da LC (QL5)" estแ disponํvel no TDN.'###"Acessar link"###"Sair"				
		ShellExecute( "Open", "http://tdn.totvs.com/pages/releaseview.action?pageId=372556085", "", "C:\", 1 )
	EndIf		
EndIf

Return nil 
//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional.

@author Paulo Carnelossi
@since 07/03/2007
@version P12.1.18

@return array, opcoes de menu da rotina
/*/
//--------------------------------------------------
Static Function MenuDef()

//Local aRotina := {}

aRotina := {}

If ( FWIsInCallStack("CTBShowFLG") )

	aAdd(aRotina,{STR0024 ,"LogVisOri", 0 , 1,}) 	// "Pesquisar"
	aAdd(aRotina,{STR0025 ,"LogVisCV3", 0 , 2}) 	// "Visualizar"
	aAdd(aRotina,{STR0026 ,"LogVisCT2", 0 , 3}) 	// "Incluir"
	aAdd(aRotina,{STR0027 ,"LogVisLeg", 0 , 4})		//"Imprime Log"
	aAdd(aRotina,{STR0042 ,"ProcLogDet",0,2})		//"Detalhes"

Else
	aAdd(aRotina,{STR0042 ,"ProcLogDet",0,2})		//"Detalhes"
EndIf				

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLogVisOri บAutor  ณMarcos S. Lobo      บ Data ณ  01/28/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza็ใo do registro de origem a partir do Browse do LOGบฑฑ
ฑฑบ          ณarquivo .FLG                   	                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - 						                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LogVisOri()

Local aAreaVis := GetArea()
Local nRecOri
Local cCadOri	:= cCadastro

If !TableInDic("QL5") //Tratamento para relises < 12.1.17
	Help(" ",1,"CTB120LOGFLAG",,STR0062,1,0,,,,,,{STR0028}) //"Localizada transfer๊ncia com data posterior a data base do sistema."###"Confira a data da ๚ltima transfer๊ncia ocorrida para o ativo: "
	Return 
EndIf

If Empty(QL5->QL5_TABORI) .or. Empty(QL5->QL5_RECORI)
	Return
EndIf

nRecOri := int(val(QL5->QL5_RECORI))

dbSelectArea(QL5->QL5_TABORI)
dbGoTo(nRecOri)
If (QL5->QL5_TABORI)->(Eof()) .or. (QL5->QL5_TABORI)->(Recno()) <> nRecOri
	RestArea(aAreaVis)
	Return
EndIf
dbSetOrder(1)

dbSelectArea("SX2")
SX2->(dbSetOrder(1))
If SX2->(dbSeek(QL5->QL5_TABORI))
	cCadastro := X2Nome()
	cCadastro := alltrim(cCadastro)+" - Record "+QL5->QL5_RECORI
EndIf

dbSelectArea(QL5->QL5_TABORI)
AxVisual(Alias(),(QL5->QL5_TABORI)->(Recno()),2)

cCadastro := cCadOri
RestArea(aAreaVis)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXFUN   บAutor  ณMicrosiga           บ Data ณ  01/29/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LogVisCV3

Local aAreaVis := GetArea()
Local nRecOri
Local cCadOri	:= cCadastro

If !TableInDic("QL5") //Tratamento para relises < 12.1.17
	Help(" ",1,"CTB120LOGFLAG",,STR0062,1,0,,,,,,{STR0028}) //"Localizada transfer๊ncia com data posterior a data base do sistema."###"Confira a data da ๚ltima transfer๊ncia ocorrida para o ativo: "
	Return 
EndIf

If Empty(QL5->QL5_RCNCV3) 
	Return
EndIf

nRecOri := int(val(QL5->QL5_RCNCV3))

dbSelectArea("CV3")
dbGoTo(nRecOri)
If CV3->(Eof()) .or. CV3->(Recno()) <> nRecOri
	RestArea(aAreaVis)
	Return
EndIf
dbSetOrder(1)

dbSelectArea("SX2")
SX2->(dbSetOrder(1))
If SX2->(dbSeek("CV3"))
	cCadastro := X2Nome()
	cCadastro := alltrim(cCadastro)+" - Record "+QL5->QL5_RCNCV3
EndIf

dbSelectArea("CV3")
AxVisual("CV3",CV3->(Recno()),2)

cCadastro := cCadOri
RestArea(aAreaVis)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLogVisCT2 บAutor  ณMarcos S. Lobo      บ Data ณ  01/28/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza็ใo do registro de LANCTO a partir do Browse do LOGบฑฑ
ฑฑบ          ณarquivo .FLG                   	                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LogVisCT2()

Local aAreaVis := GetArea()
Local nRecCT2
Local cCadOri	:= cCadastro

If !TableInDic("QL5") //Tratamento para relises < 12.1.17
	Help(" ",1,"CTB120LOGFLAG",,STR0062,1,0,,,,,,{STR0028}) //"Localizada transfer๊ncia com data posterior a data base do sistema."###"Confira a data da ๚ltima transfer๊ncia ocorrida para o ativo: "
	Return 
EndIf

nRecCT2 := int(val(QL5->QL5_RCNCT2))

dbSelectArea("CT2")
dbGoTo(nRecCT2)
If CT2->(Eof()) .or. CT2->(Recno()) <> nRecCT2
	RestArea(aAreaVis)
	Return
EndIf
dbSetOrder(1)

dbSelectArea("SX2")
SX2->(dbSetOrder(1))
If SX2->(dbSeek("CT2"))
	cCadastro := X2Nome()
	cCadastro := alltrim(cCadastro)+" - Record "+QL5->QL5_RCNCT2
EndIf

dbSelectArea("CT2")
If CT2->(Deleted())
	cCadastro += " jแ excluํdo."
EndIf

AxVisual("CT2",Recno(),2)

cCadastro := cCadOri
RestArea(aAreaVis)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXFUN   บAutor  ณMicrosiga           บ Data ณ  01/29/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LogVisLeg

Aviso(	STR0029+" - "+STR0030,;  		//"Tipos de registro"#"Log de Limpeza de Flags de Contabiliza็ใo"
					STR0031+CRLF+;		//"0 = Log - Exclusao Lan็amento efetuada, remarcacao flags OK"
					STR0032+CRLF+;		//"1 = Erro - Tabela ou Registro de origem no rastreamento em branco."
					STR0033+CRLF+;		//"2 = Erro - Registro nใo encontrado na tabela de origem."
					STR0034+CRLF+;		//"3 = Erro - Registro nใo encontrado na tabela rastreamento (CV3)."
					STR0035+CRLF+;		//"4 = Log - Exclusao Documento, usuario optou por nใo remarcar flags."
					STR0036,{},3,"")	//"5 = Log - Excluso de Linha Lancamento, usuario optou por nใo remarcar flags."

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณBatchLogณ Autor ณ Edson Maricate          ณ Data ณ 31.01.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma FormBatch com utilizacao de Log.                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ BatchLog(cTitle,aSays,aButtons,bValid,nAltura,nLargura)    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ cTitle = Titulo da janela											  ณฑฑ
ฑฑณ			 ณ aSays  = Array com Says 											  ณฑฑ
ฑฑณ			 ณ aButtons = Array com bottoes										  ณฑฑ
ฑฑณ			 ณ aButtons[i,1] = Tipo de botao 									  ณฑฑ
ฑฑณ			 ณ aButtons[i,2] = Tipo de enabled									  ณฑฑ
ฑฑณ			 ณ aButtons[i,3] = bAction 											  ณฑฑ
ฑฑณ			 ณ bValid = Bloco de validacao do Form 							  ณฑฑ
ฑฑณ			 ณ nAltura= Altura do Form em Pixel (Default 250)				  ณฑฑ
ฑฑณ			 ณ nLargura = Largura do Form em Pixel (Default 520)			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ProcLogIni( aButtons,cProcess,cSubProcess,cIdCV8,cFilProc)
Local aAreaAnt	:= GetArea()
Local cFilOld	:= ''
Default cProcess	:= ProcName(1)
Default cSubProcess	:= ""
Default aButtons	:= {}
Default cFilProc	:= cFilAnt

If cFilProc != cFilAnt
	cFilOld := cFilAnt
	cFilAnt := cFilProc
EndIf

If Empty(__BatchProc)
	__BatchProc := cProcess
Else
	__SubProc := cProcess
EndIf

If !Empty(cProcess)
	__BatchProc := cProcess 
EndIf

If !Empty(cSubProcess)
	__SubProc := cSubProcess 
EndIf

If !Empty(CV8->(IndexKey(5))) 
	__cIdCV8:= GetSXENum("CV8","CV8_IDMOV",,5)	
	cIdCV8 	:= __cIdCV8
	ConfirmSX8()
EndIf

aadd(aButtons, { 15,.T.,{|| ProcLogView()  } } )

If !Empty(cFilOld)
	cFilAnt := cFilOld
EndIf

RestArea(aAreaAnt)
Return 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณBatchLogณ Autor ณ Edson Maricate          ณ Data ณ 31.01.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma FormBatch com utilizacao de Log.                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ BatchLog(cTitle,aSays,aButtons,bValid,nAltura,nLargura)    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ cTitle = Titulo da janela											  ณฑฑ
ฑฑณ			 ณ aSays  = Array com Says 											  ณฑฑ
ฑฑณ			 ณ aButtons = Array com bottoes										  ณฑฑ
ฑฑณ			 ณ aButtons[i,1] = Tipo de botao 									  ณฑฑ
ฑฑณ			 ณ aButtons[i,2] = Tipo de enabled									  ณฑฑ
ฑฑณ			 ณ aButtons[i,3] = bAction 											  ณฑฑ
ฑฑณ			 ณ bValid = Bloco de validacao do Form 							  ณฑฑ
ฑฑณ			 ณ nAltura= Altura do Form em Pixel (Default 250)				  ณฑฑ
ฑฑณ			 ณ nLargura = Largura do Form em Pixel (Default 520)			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ProcLogView(cFilProc,cProc,cSubProc,cIdCV8)
Local aAreaAnt  := GetArea()
Local cFilterIni:= ""
Local cFilterFin:= ""   
Local cChave	:= "" 

Private aRotina 	:= {}
Default cProc 		:= __BatchProc  
Default cSubProc 	:= ""
Default cFilProc 	:= cFilAnt

If Type("cCadastro") != "C"
	cCadastro := ""
EndIf

__BatchProc := cProc

aRotina := MenuDef()

//Criado parametro para filtro
dbSelectArea("CV8")

If !Empty(cIdCV8) .And. CV8->(FieldPos("CV8_IDMOV")) > 0
	dbSetOrder(5) //CV8_FILIAL+CV8_IDMOV
	cFilterIni := 'xFilial("CV8","'+cFilProc+'")+"'+cIdCV8+'"'
	cFilterFin := 'xFilial("CV8","'+cFilProc+'")+"'+cIdCV8+'"'
	cChave := xFilial("CV8")+cIdCV8
ElseIf !Empty(cSubProc) .And. CV8->(FieldPos("CV8_SBPROC")) > 0
	dbSetOrder(4) //CV8_FILIAL+CV8_PROC+CV8_SBPROC+CV8_USER+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni := 'xFilial("CV8","'+cFilProc+'")+"'+cProc+cSubProc+'"'
	cFilterFin := 'xFilial("CV8","'+cFilProc+'")+"'+cProc+cSubProc+'"' 
	cChave := xFilial("CV8")+cProc+cSubProc
Else
	dbSetOrder(1) //CV8_FILIAL+CV8_PROC+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni :='xFilial("CV8")+"'+cProc+'"'
	cFilterFin :='xFilial("CV8")+"'+cProc+'zzzzzzzzzzz"'                    
	cChave := xFilial("CV8")+cProc
EndIf 

MaWndBrowse(0,0,500,780,STR0037+" - "+cCadastro,"CV8",,aRotina,"CV8->CV8_INFO=='4'",;
cFilterIni,;
cFilterFin,;
.T.,{{"OK",STR0038},{"CANCEL",STR0039}},2,{{STR0040,1},{STR0041,2}}, cChave ,,,,,,,,,,,,,,,, ".F." )  //"Avisos"##"Erro de processamento"##"Data+Hora"##"Usuario+Data+Hora"

RestArea(aAreaAnt)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณProcLogDetณ Autor ณ Renato / Davi		    ณ Data ณ 14.11.07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Exibe o detalhamento dos logs 			                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ProcLogDet()												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ProcLogDet(cAlias,nRecno,nOpc,oBrowse)

	Default cAlias  := Alias()
	Default nRecno  := Recno()
	Default nOpc    := 2
	Default oBrowse := NIL

	//Verifica a existencia da CV8 antes de visualizar o registro
	If PrLogSeek(oBrowse)
		AxVisual("CV8",CV8->(Recno()),2)
	Else
		Help(' ',1,'ARQVAZIO')
	Endif	

Return()

/*/{Protheus.doc} PrLogSeek()
	Verifica se o registro existe na CV8, antes de executar a visualiza็ใo

	@type Static Function
	@author Vitor Duca
	@since 29/01/2021
	@param oBrowse , Objeto, objeto do Browse que sera verificado
	@version 1.0
/*/
Static Function PrLogSeek(oBrowse)
	Local aArea  	As Array
	Local aAreaCV8 	As Array
	Local lRet		As Logical

	Default oBrowse := NIL
	
	aArea  		:= GetArea() 
	aAreaCV8 	:= CV8->(GetArea())
	lRet		:= .T.

	If oBrowse <> NIL .and. !Eval(oBrowse:bGotop)
		lRet := .F.
	Endif

	RestArea(aAreaCV8)
	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณBatchLogณ Autor ณ Edson Maricate          ณ Data ณ 31.01.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma FormBatch com utilizacao de Log.                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ BatchLog(cTitle,aSays,aButtons,bValid,nAltura,nLargura)    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ProcLogAtu(cType,cMsg,cDetalhes,cBatchProc,lCabec,cFilProc)
Local nx
Local aAreaAnt		:= GetArea()
Local cMsgSubProc	:= ""
Local cFilOld		:= cFilAnt

Default cDetalhes   := ""
Default cMsg		:= ""
Default cType		:= "INICIO"
Default lCabec		:= Nil
Default cFilProc	:= cFilAnt

If cFilProc != cFilAnt
	cFilAnt := cFilProc
EndIf

If  cBatchProc <> Nil
	__BatchProc  := cBatchProc
Endif

If !Empty(__BatchProc)
	Do Case
		Case cType == "INICIO" // Inicio do Processamento
			cMsg := STR0043+cMsg    //"Processamento iniciado. "
			cType := "1"
   		For nx := 1 to 30
				If Type('mv_par'+StrZero(nx,2)) <> "U"
					If !Empty(ToXlsFormat(&('mv_par'+StrZero(nx,2))))
						cDetalhes += STR0044+StrZero(nx,2)+" : "+ToXlsFormat(&('mv_par'+StrZero(nx,2)))+CHR(13)+CHR(10)   //"Parametro "
					EndIf
				EndIf
			Next
		Case cType == "FIM" // Final do Processamento
			cMsg := STR0045+cMsg  //"Processamento encerrado. "
			cType := "2"
		Case cType == "ALERTA" // Alerta
			cMsg := STR0046+cMsg  //"Alerta! "
			cType := "3"
		Case cType == "ERRO" // Erro 
			cMsg := STR0047+cMsg  //"Erro de Processamento. "
			cType := "4"
		Case cType == "CANCEL" // Cancelado pelo usuario
			cMsg := STR0048+cMsg  //"Processamento cancelado pelo usuario. "
			cType := "5"
		Case cType == "MENSAGEM" // Mensagem
			cMsg := STR0049+cMsg  //"Mensagem : "
			cType := "6"
	EndCase	

	cMsgSubProc	:= cMsg+STR0050+__BatchProc 								//" Executado por :"
	cMsg		:= If(!Empty(__SubProc),STR0051+__SubProc+" - ","")+cMsg	//"Sub-Processo : "

	GravaCV8(cType, __BatchProc, cMsg, cDetalhes, __SubProc, cMsgSubProc, lCabec, __cIdCV8, cFilProc)

	If cType == "2" // Final do Processamento
		__BatchProc := ""
		__SubProc	:= ""
	EndIf

EndIf	

cFilAnt := cFilOld

RestArea(aAreaAnt)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXFUNA  บAutor  ณMarcos S. Lobo      บ Data ณ  01/17/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLog de processamento com impressao em relatorio.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ConOutR(cTexto,lFim,cProcesso)

If __MvConOutR == Nil
	__MvConOutR := GetNewPar("MV_CONOUTR",0)
EndIf

DEFAULT cTexto		:= ""
DEFAULT lFim		:= .F.
DEFAULT cProcesso	:= "CTBA105"

If __lLogCTB == Nil
	__lLogCTB := If(__MvConOutR >= 1,.T.,.F.)
EndIf

If !__lLogCTB
	Return
EndIf

cTxtLog := cProcesso+"|"+cUserName+"|"+STR(THREADID())+"|"+Dtoc(Date())+"|"+Time()+"|"+ALLTRIM(STR(SECONDS()))+"|"
cTxtLog += cTexto

If __MvConOutR >= 2
	CONOUT(cTxtLog)
EndIf

If __PEConOutR == Nil
	__PEConOutR := ExistBlock("CONOUTR")
EndIf
If __PEConOutR
	ExecBlock("CONOUTR",.F.,.F.)
EndIf

If ValType(aTxt) == "U"
	aTxt := {}
Endif

aAdd(aTxt,cTxtLog)

If !lFim .or. IsBlind() .or. __MvConOutR >= 3
	Return
EndIf

If !MsgYesNo(STR0052+cProcesso+" ?","MV_CONOUTR "+STR0053)//"Imprime Log do processo "//"TraceLog de Processamento"
	If MsgYesNo(STR0054+STR0055+" MV_CONOUTR."+CRLF+STR0056,STR0053)//"Importante, o uso de Trace/Log de processo pode interferir na performance do sistema."//" Avalie com o Administrador a configura็ใo do Log atrav้s do parโmetro
																	//"Cancelar a execu็ใo deste Log ?"//"TraceLog de Processamento"
		__lLogCTB := .F.
	EndIf
	Return
EndIf

CtRConOut(aTxt)

aTxt := {}

If MsgYesNo(STR0054+STR0055+" MV_CONOUTR."+CRLF+STR0056,STR0053)//"Importante, o uso de Trace/Log de processo pode interferir na performance do sistema."//" Avalie com o Administrador a configura็ใo do Log atrav้s do parโmetro
																	//"Cancelar a execu็ใo deste Log ?"//"TraceLog de Processamento"
	__lLogCTB := .F.
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBXFUNA  บAutor  ณMicrosiga           บ Data ณ  01/17/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtRConOut(aTxt)
Local cPict          := ""
Local imprime        := .T.

Private cDesc1       := STR0058 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := STR0059 //"com o Trace/Log de Processamento."
Private cDesc3       := STR0053 //"Trace/Log Processamento"
Private titulo       := STR0053 //"Trace/Log Processamento"
Private nLin         := 80

Private Cabec1       := "Trace/Log Processamento"
Private Cabec2       := ""
Private aOrd         := {}
Private lEnd         := .F.
Private limite       := 220
Private tamanho      := "M"
Private nomeprog     := "CTBXFUN" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 10
Private aReturn      := { "Zebrado", 1, STR0061, 2, 2, 1, "", 1}///"Administracao"
Private nLastKey     := 0
Private cPerg        := "CONOUTR"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 1
Private wnrel        := "CONOUTR"//+ALLTRIM(cUserName)//Coloque aqui o nome do arquivo usado para impressao em disco
Private nOrdem       := 1
Private cString      := "CT1"

dbSelectArea( "CT1" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

  SetDefault( aReturn , cString ,,,"M" , 2 ) 

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,10,15)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|lEnd| RunCtROut(lEnd,WnRel,cString,nOrdem,aTxt)},Titulo)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRunCtROut บ Autor ณ AP6 IDE            บ Data ณ  17/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunCtROut(lEnd,WnRel,cString,nOrdem,aTxt)

Local nTxt

dbSelectArea(cString)
dbSetOrder(1)
SetRegua(RecCount())

Pergunte("CTRFCONT", .F.)

For nTxt := 1 to Len(aTxt)

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If lEnd
      @nLin,00 PSAY STR0060  //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Impressao do cabecalho do relatorio. . .                            ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 59 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

    @nLin,00 PSAY aTxt[nTxt]

   nLin := nLin + 1 // Avanca a linha de impressao
Next
              
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} CtbChkPar()
Verifica se o mv_par?? existe

@author totvs
@since 27/09/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CtbChkPar(cMVParAux)
Return (Type(cMVParAux)<>"U")
