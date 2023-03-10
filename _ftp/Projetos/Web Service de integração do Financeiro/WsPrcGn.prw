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
	WSDATA De       AS STRING
	WSDATA Ate      AS STRING

	WSMETHOD POST         DESCRIPTION 'Adiciona dados a serem processados por rotinas específicas do protheus.' WSSYNTAX '/' PATH '/'
	WSMETHOD GET  ID      DESCRIPTION 'Consulta o status de um processamento enviado ao protheus.' WSSYNTAX '/' PATH '/'
	WSMETHOD GET  FINA040 DESCRIPTION 'Consulta dados de um título a receber.' WSSYNTAX '/FINA040/' PATH '/FINA040/'
	WSMETHOD GET  FINA050 DESCRIPTION 'Consulta dados de um título a pagar.' WSSYNTAX '/FINA050/' PATH '/FINA050/'
	WSMETHOD GET  FINA070 DESCRIPTION 'Consulta de títulos a receber baixados em um período.' WSSYNTAX '/FINA070/' PATH '/FINA070/'
	WSMETHOD GET  FINA080 DESCRIPTION 'Consulta de títulos a pagar baixados em um período.' WSSYNTAX '/FINA080/' PATH '/FINA080/'

END WSRESTFUL

/** 

POST 
Adiciona dados a serem processados por rotinas específicas do protheus.

**/

WSMETHOD POST WSRECEIVE Rotina, Operacao WSRESTFUL WsPrcGn

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

WSMETHOD GET FINA040 WSRECEIVE Prefixo, Numero, Parcela, Tipo WSRESTFUL WsPrcGn

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

WSMETHOD GET FINA050 WSRECEIVE Prefixo, Numero, Parcela, Tipo WSRESTFUL WsPrcGn

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

/** 

GET FINA070
Consulta de títulos a receber baixados em um período.

**/

WSMETHOD GET FINA070 WSRECEIVE De, Ate WSRESTFUL WsPrcGn

	Default ::De  := ''
	Default ::Ate := ''

return getContent( 'SE1', self ) 

/** 

GET FINA080
Consulta de títulos a pagar baixados em um período.

**/

WSMETHOD GET FINA080 WSRECEIVE De, Ate WSRESTFUL WsPrcGn

	Default ::De  := ''
	Default ::Ate := ''

return getContent( 'SE2', self ) 

static function getContent( cTable, _self ) 

	local jRequest  := jsonObject():New() 
	local jResponse := jsonObject():New()
	local cCampos   := ''
	local cMsg      := ''
	local aList     := {}

	_self:SetContentType( 'application/json' )
	
	jRequest:fromJson( DecodeUtf8( _self:GetContent() ) )

	validaCpos( jRequest, cTable, @cCampos, @cMsg )

	if !Empty( cMsg )

		SetRestFault( 400, FWhttpEncode( cMsg ) )

		return .F.

	end if

	aList := runQuery( cCampos, cTable, _self:De, _self:Ate )

	if !Empty( aList )

		jResponse:set( aList )

		_self:SetResponse( FWhttpEncode( jResponse:toJson() ) )

	else

		SetRestFault( 404, FWhttpEncode( 'Não foram localizados títulos baixados neste período.' ) )

		return .F.

	end if

return .T.

static function validaCpos( aCampos, cPrefix, cCampos, cMsg )

	local aArea      := getArea()
	local aAreaSx3   := SX3->( getArea() )
	local aErrorCpos := {}
	local nX         := 0
	local nLength    := len( aCampos )
	local cCampo     := ''

	SX3->( DbSetOrder( 2 ) ) // X3_CAMPO

	for nX := 1 to nLength

		cCampo := upper( allTrim( aCampos[ nX ] ) )
		cCampos += cCampo 

		if nX < nLength

			cCampos += ','
		
		end if

		if SX3->( ! DbSeek( cCampo ) ) .Or. SubStr( cCampo, 1, 3 ) != SubStr( cPrefix, 2, 2 ) + '_';
			.Or. GetSx3Cache( cCampo, 'X3_CONTEXT' ) == 'V'

			aAdd( aErrorCpos, cCampo )

		end if

	next nX

	SX3->( restArea( aAreaSx3 ) )
	restArea( aArea )

	nLength := len( aErrorCpos )

	if !Empty( aErrorCpos )

		cMsg := 'Os campos a seguir são inválidos, pois não existem fisicamente na tabela ' + cPrefix + CRLF + '[ '

		for nX := 1 to nLength

				cMsg += aErrorCpos[ nX ]

			if nX < nLength

				cMsg += ','

			end if

		next nX

		cMsg += ' ]'

	end if

return

static function runQuery( cCampos, cTable, cDe, cAte )

	local cQuery  := ''
	local cPrefix := SubStr( cTable, 2, 2 )
	local cAlias  := ''
	local aList   := {}
	local nX      := 0
	local jAux    := nil

	cQuery += " SELECT " + cCampos 
	cQuery += " FROM " + retSqlName( cTable ) 
	cQuery += " WHERE " + cPrefix + "_BAIXA BETWEEN '" + cDe + "' AND '" +  cAte + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' AND " + cPrefix + "_FILIAL = '" + xFilial( 'S' + cPrefix ) + "' "

	cAlias := MpSysOpenQuery( cQuery )

	while ( cAlias )->( !Eof() )

		jAux := jsonObject():new()

		for nX := 1 to ( cAlias )->( FCount() )

			( cAlias )->( jAux[ FieldName( nX ) ] := &( FieldName( nX ) ) )

		next nX

		aAdd( aList, jAux )

		( cAlias )->( DbSkip() )

	endDo

	( cAlias )->( DbCloseArea() )

return aList

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
