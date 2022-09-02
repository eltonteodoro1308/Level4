#include 'totvs.ch'
#include 'restful.ch'

WSRESTFUL WsPrcGn DESCRIPTION "Web Service de Integração com o Protheus." FORMAT APPLICATION_JSON

	WSDATA Rotina   AS STRING
	WSDATA Operacao AS STRING
	WSDATA Id       AS STRING
	WSDATA Prefixo  AS STRING
	WSDATA Numero   AS STRING
	WSDATA Parcela  AS STRING
	WSDATA Tipo     AS STRING

	WSMETHOD POST         DESCRIPTION 'Adiciona dados a serem processados por rotinas específicas do protheus.' WSSYNTAX '/' PATH '/'
	WSMETHOD GET  ID      DESCRIPTION 'Consulta o status de um processamento enviado ao protheus.' WSSYNTAX '/' PATH '/'
	WSMETHOD GET  FINA040 DESCRIPTION 'Consulta o status de um processamento enviado ao protheus.' WSSYNTAX '/FINA040/' PATH '/FINA040/'
	WSMETHOD GET  FINA050 DESCRIPTION 'Consulta o status de um processamento enviado ao protheus.' WSSYNTAX '/FINA050/' PATH '/FINA050/'

END WSRESTFUL

/** 

POST 
Adiciona dados a serem processados por rotinas específicas do protheus.

**/

WSMETHOD POST WSRECEIVE Rotina WSRESTFUL WsPrcGn

local cId   := FwUUIDV4(.F.)
local cBody := ''

Default ::Rotina := ''
Default ::Operacao := '3'

::SetContentType( 'application/json' )

if Empty( ::Rotina )

	SetRestFault( 400, FWhttpEncode( 'É obrigatório indicar a rotina a ser processada.' ) )

	return .F.

end if

RecLock( 'SZ1', .T. )

SZ1->Z1_FILIAL  := SM0->M0_CODFIL
SZ1->Z1_UUID    := cId
SZ1->Z1_DATAINC := Date()
SZ1->Z1_HORAINC := Time()
SZ1->Z1_ROTINA  := ::Rotina
SZ1->Z1_BODYMSG := DecodeUtf8( ::GetContent() )
SZ1->Z1_STATUS  := '0'
SZ1->Z1_OPERACA := ::Operacao

SZ1->( MsUnlock() )

if lower( AllTrim( ::GetHeader( 'Communication' ) ) ) == 'sync'

	U_pWsPrcGn( cId )

end if

if getPrcStat( cId, @cBody )

	::SetResponse( cBody )

else

	SetRestFault( 404, FWhttpEncode( 'id não localizado na base.' ) )

	return .F.

end if

Return .T.

/** 

GET ID 
Consulta o status de um processamento enviado ao protheus.

**/

WSMETHOD GET ID WSRECEIVE Id WSRESTFUL WsPrcGn

local cBody := ''

::SetContentType( 'application/json' )

if getPrcStat( ::id, @cBody )

	::SetResponse( cBody )

else

	SetRestFault( 404, FWhttpEncode( 'id não localizado na base.' ) )

	return .F.

end if

return .T.

/** 

GET FINA040
Consulta dados de um título a receber.

**/

WSMETHOD GET FINA040 WSRECEIVE Id WSRESTFUL WsPrcGn

	Local cSeek     := xFilial( 'SE1' )
	local jRequest  := jsonObject():New() 
	local jResponse := jsonObject():New()
	local nX        := 0 
	local cCampo    := ''
	local xValor    := nil

	Default ::Prefixo := ''
	Default ::Numero  := ''
	Default ::Parcela := ''
	Default ::Tipo    := ''

	::SetContentType( 'application/json' )

	cSeek += PadR( ::Prefixo, GetSx3Cache( 'E1_PREFIXO' , 'X3_TAMANHO' ) )
	cSeek += PadR( ::Numero , GetSx3Cache( 'E1_NUM'     , 'X3_TAMANHO' ) )
	cSeek += PadR( ::Parcela, GetSx3Cache( 'E1_PARCELA' , 'X3_TAMANHO' ) )
	cSeek += PadR( ::Tipo   , GetSx3Cache( 'E1_TIPO'    , 'X3_TAMANHO' ) )

	DbSelectArea( 'SE1' )
	SE1->( DbSetOrder( 1 ) )

	if SE1->( DbSeek( cSeek ) )

		jRequest:fromJson( DecodeUtf8( ::GetContent() ) )
		SX3->( DbSetOrder( 2 ) )

		for nX := 1 to len( jRequest )

			if SX3->( DbSeek( jRequest[ nX ] ) .And. AllTrim( jRequest[ nX ] ) == AllTrim( X3_CAMPO ) )

				cCampo := jRequest[ nX ]

				if SX3->X3_TIPO == 'C'

					xValor := AllTrim( SE1->( &( cCampo ) ) )

				else

					xValor := SE1->( &( cCampo ) )

				end if

				jResponse[ cCampo ] := xValor
		
			end if

		next nX

		::SetResponse( FWhttpEncode( jResponse:toJson() ) )

	else

		SetRestFault( 404, FWhttpEncode( 'Título não localizado na base.' ) )

		return .F.

	end if

Return .T.

/** 

GET FINA050
Consulta dados de um título a pagar.

**/

WSMETHOD GET FINA050 WSRECEIVE Id WSRESTFUL WsPrcGn

	Local cSeek     := xFilial( 'SE2' )
	local jRequest  := jsonObject():New() 
	local jResponse := jsonObject():New()
	local nX        := 0 
	local cCampo    := ''
	local xValor    := nil

	Default ::Prefixo := ''
	Default ::Numero  := ''
	Default ::Parcela := ''
	Default ::Tipo    := ''

	::SetContentType( 'application/json' )

	cSeek += PadR( ::Prefixo, GetSx3Cache( 'E2_PREFIXO' , 'X3_TAMANHO' ) )
	cSeek += PadR( ::Numero , GetSx3Cache( 'E2_NUM'     , 'X3_TAMANHO' ) )
	cSeek += PadR( ::Parcela, GetSx3Cache( 'E2_PARCELA' , 'X3_TAMANHO' ) )
	cSeek += PadR( ::Tipo   , GetSx3Cache( 'E2_TIPO'    , 'X3_TAMANHO' ) )

	DbSelectArea( 'SE2' )
	SE2->( DbSetOrder( 1 ) )

	if SE2->( DbSeek( cSeek ) )

		jRequest:fromJson( DecodeUtf8( ::GetContent() ) )
		SX3->( DbSetOrder( 2 ) )

		for nX := 1 to len( jRequest )

			if SX3->( DbSeek( jRequest[ nX ] ) .And. AllTrim( jRequest[ nX ] ) == AllTrim( X3_CAMPO ) )

				cCampo := jRequest[ nX ]

				if SX3->X3_TIPO == 'C'

					xValor := AllTrim( SE2->( &( cCampo ) ) )

				else

					xValor := SE2->( &( cCampo ) )

				end if

				jResponse[ cCampo ] := xValor
		
			end if

		next nX

		::SetResponse( FWhttpEncode( jResponse:toJson() ) )

	else

		SetRestFault( 404, FWhttpEncode( 'Título não localizado na base.' ) )

		return .F.

	end if

Return .T.


/*/{Protheus.doc} getPrcStat
Busca na tabela SZ1 os dados de um processamento e popula a variável
cBody recebida por referência
@type function
@version  12.1.33
@author elton.alves@totvs.com.br
@since 14/04/2022
@param cId, character, Id do processamento da busca
@param cBody, character, Variável recebida por referência a ser populado com os dados do processamento
@return logical, indica se o id do processamento foi localizado
/*/
static function getPrcStat( cId, cBody )

	local nX    := 0
	local oJson := jsonObject():New()
	local cseek := xFilial( 'SZ1' ) + cId

	DbSelectArea( 'SZ1' )
	SZ1->( DbSetOrder( 1 ) )

	if DbSeek( cSeek ) .And. AllTrim( cSeek ) == AllTrim( SZ1->( Z1_FILIAL + Z1_UUID ) )

		For nX := 1 To SZ1->( FCount() )

			SZ1->( oJson[FieldName( nX )] := &( FieldName( nX ) ) )

		Next nX

	else

		return .F.

	end if

	cBody := FWhttpEncode( oJson:toJson() )

return .T.
