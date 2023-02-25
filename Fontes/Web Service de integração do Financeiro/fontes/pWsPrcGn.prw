#include 'totvs.ch'

/*/{Protheus.doc} pWsPrcGn
Rotina que recebe um id de um processamento da tabela SZ1 e processa o mesmo
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
@param cId, character, id do processamento a ser executado
/*/
user function pWsPrcGn( cId )

	local cRotina := ''
	local cSeek   := xFilial( 'SZ1' ) + cId
	local cError  := ''
	Local bError  := ErrorBlock( { | oErro | cErro := oErro:Description } )
	Local aArea   := getArea()

	DbSelectArea( 'SZ1' )
	SZ1->( DbSetOrder( 1 ) )

	restArea( aArea )

	if SZ1->( DbSeek( cSeek ) ) .And. AllTrim( cSeek ) == AllTrim( SZ1->( Z1_FILIAL + Z1_UUID ) )

		cRotina := AllTrim( Upper( SZ1->Z1_ROTINA ) )

		if cRotina == 'FINA040' // Contas a Receber

			pFina040()

		elseif cRotina == 'FINA050' // Contas a Pagar

			pFina050()

		else

			regSZ1( '1', 'Rotina não tem processamento definido.' )

		endif

		if !Empty( cError )

			regSZ1( '2', cError )

		end if

	else

		ConOut( 'id: ' + cId + ' não localizado para filial: ' + SM0->M0_CODFIL )

	end if

	ErrorBlock( bError )

return

/*/{Protheus.doc} pFina040
Rotina que executa o processamento de inclusão do contas a receber
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
/*/
static function pFina040()

	local oJson     := jsonObject():New()
	local aJsonProp := {}
	local aSe1      := {}
	local nX        := 0
	local cCampo    := ''
	local xValor    := ''
	local cType     := ''
	local aErro     := {}
	local cErro     := ''
	local lContaOk  := .T.
	local nPos      := 0

	private lMsErroAuto    := .F.
	private lMsHelpAuto    := .T.
	private lAutoErrNoFile := .T.

	oJson:fromJson( SZ1->Z1_BODYMSG )

	aJsonProp := aClone( ClassDataArr( oJson ) )

	nPos := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'E1_TIPO' } )

	if nPos > 0 .And. upper( alltrim( aJsonProp[ nPos, 2 ] ) ) == 'RA'

		lContaOk := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'CBCOAUTO' } ) > 0
		lContaOk := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'CAGEAUTO' } ) > 0 .And. lContaOk
		lContaOk := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'CCTAAUTO' } ) > 0 .And. lContaOk

	end if

	if ! lContaOk

		cErro +=  'Para inclusão de Recebimento Antecipado ( E1_TIPO = "RA" ) as propriedades a seguir são obrigatórias:' + CRLF
		cErro +=  'CBCOAUTO -> Código do Banco' + CRLF
		cErro +=  'CAGEAUTO -> Código da Agência' + CRLF
		cErro +=  'CCTAAUTO -> Conta Bancária'  + CRLF

	else

		for nX := 1 to Len( aJsonProp )

			cCampo := aJsonProp[ nX, 1 ]
			xValor := aJsonProp[ nX, 2 ]

			cType := GetSx3Cache( cCampo, 'X3_TIPO' )

			if ! Empty( cType ) .And. cType == 'D'

				xValor := StoD( xValor )

			elseif ! Empty( cType ) .And. cType == 'C'

				xValor := PadR( xValor, GetSx3Cache( cCampo, 'X3_TAMANHO' ) )

			end if

			aAdd( aSe1, { cCampo, xValor, nil } )

		next nx

		aSe1 := ordemSX3( aSe1 )

		Begin Transaction

			MsExecAuto( { | x, y | FINA040( x, y ) } , aSe1, val( SZ1->Z1_OPERACA ) )

			if lMsErroAuto

				lMsErroAuto := .F.

				aErro := aClone( GetAutoGRLog() )

				for nX := 1 to Len( aErro )

					cErro += aErro[ nX ] + CRLF

				next nX

				DisarmTransaction()

			endif

		End Transaction

	end if

	if Empty( cErro )

		regSZ1( '1', 'Contas a Receber processado com sucesso.' )

	else

		regSZ1( '2', cErro )

	endif

return

/*/{Protheus.doc} pFina050
Rotina que executa o processamento de inclusão do contas a pagar
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
/*/
static function pFina050()

	local oJson     := jsonObject():New()
	local aJsonProp := {}
	local aSe2      := {}
	local nX        := 0
	local cCampo    := ''
	local xValor    := ''
	local cType     := ''
	local aErro     := {}
	local cErro     := ''
	local lContaOk  := .T.
	local nPos      := 0
	local nOperacao := val( SZ1->Z1_OPERACA )
	local cSeek     := xFilial( 'SE2' )

	private lMsErroAuto    := .F.
	private lMsHelpAuto    := .T.
	private lAutoErrNoFile := .T.

	oJson:fromJson( SZ1->Z1_BODYMSG )

	cSeek += PadR( cValToChar( oJson[ 'E2_PREFIXO' ] ), GetSx3Cache( 'E2_PREFIXO', 'X3_TAMANHO' ) )
	cSeek += PadR( cValToChar( oJson[ 'E2_NUM'     ] ), GetSx3Cache( 'E2_NUM'    , 'X3_TAMANHO' ) )
	cSeek += PadR( cValToChar( oJson[ 'E2_PARCELA' ] ), GetSx3Cache( 'E2_PARCELA', 'X3_TAMANHO' ) )
	cSeek += PadR( cValToChar( oJson[ 'E2_TIPO'    ] ), GetSx3Cache( 'E2_TIPO'   , 'X3_TAMANHO' ) )

	aJsonProp := aClone( ClassDataArr( oJson ) )

	private lCnab := ! Empty( oJson['AUTCNAB'] )

	nPos := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'E2_TIPO' } )

	private lIsPa := upper( alltrim( aJsonProp[ nPos, 2 ] ) ) == 'PA'

	if nPos > 0 .And. lIsPa

		lContaOk := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'AUTBANCO' } ) > 0
		lContaOk := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'AUTAGENCIA' } ) > 0 .And. lContaOk
		lContaOk := aScan( aJsonProp, { | item | upper(alltrim( item[ 1 ] ) ) == 'AUTCONTA' } ) > 0 .And. lContaOk

	end if

	if ! lContaOk

		cErro +=  'Para inclusão de Pagamento Antecipado ( E2_TIPO = "PA" ) as propriedades a seguir são obrigatórias:' + CRLF
		cErro +=  'AUTBANCO -> Código do Banco' + CRLF
		cErro +=  'AUTAGENCIA -> Código da Agência' + CRLF
		cErro +=  'AUTCONTA -> Conta Bancária'  + CRLF

	else

		for nX := 1 to Len( aJsonProp )

			if aJsonProp[ nX, 1 ] != "AUTCNAB"

				cCampo := aJsonProp[ nX, 1 ]
				xValor := aJsonProp[ nX, 2 ]

				cType := GetSx3Cache( cCampo, 'X3_TIPO' )

				if ! Empty( cType ) .And. cType == 'D'

					xValor := StoD( xValor )

				elseif ! Empty( cType ) .And. cType == 'C'

					xValor := PadR( xValor, GetSx3Cache( cCampo, 'X3_TAMANHO' ) )

				end if

				aAdd( aSe2, { cCampo, xValor, nil } )

			end if

		next nx

		aSe2 := ordemSX3( aSe2 )

		Begin Transaction

			if cValTochar( nOperacao ) $ '345'

				DbSelectArea( 'SE2' )
				SE2->( DbSetOrder( 1 ) )

				if nOperacao == 3 .Or.;
						( cValToChar( nOperacao ) $ '45' .And. SE2->( DbSeek( cSeek ) ) .And.;
						cSeek == SE2->( E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO ) )

					MsExecAuto( { | x, y, z | FINA050( x, y, z ) } , aSe2,, nOperacao )

				else

					cErro := 'Título não localizado na base.'

				end if

			else

				cErro := 'Informe um operação válida.'

			end if

			if lMsErroAuto

				lMsErroAuto := .F.

				aErro := aClone( GetAutoGRLog() )

				for nX := 1 to Len( aErro )

					cErro += aErro[ nX ] + CRLF

				next nX

				DisarmTransaction()

			endif

		End Transaction

	end if

	if Empty( cErro )

		regSZ1( '1', 'Contas a Pagar processado com sucesso.' )

	else

		regSZ1( '2', cErro )

	endif

return

/*/{Protheus.doc} ordemSX3
Coloca a lista de campo do array de um execauto na ordem do dicionário de dados
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
@param aLstCpos, array, Array com a lista de campos a ser ordenada
@return array, Array com a lista de campos ordenada
/*/
static function ordemSX3( aLstCpos )

	local aOrdem   := {}
	local aRet     := {}
	local nX       := 0
	local cOrdem   := ''
	local nPos     := 0

	for nX := 1 to len( aLstCpos )

		cOrdem := GetSx3Cache( aLstCpos[nX,1], 'X3_ORDEM' )

		if ! empty( cOrdem )

			aAdd( aOrdem, { cOrdem, aLstCpos[nX,1] } )

		else

			aAdd( aRet, { aLstCpos[nX,1], aLstCpos[nX,2], nil } )

		end if

	next nX

	aSort( aOrdem,,, { | x, y | x[ 1 ] < y[ 1 ] } )

	for nx := 1 to len( aOrdem )

		nPos := aScan( aLstCpos, { | x | x[ 1 ] == aOrdem[ nX, 2 ] } )

		if nPos > 0

			aAdd( aRet, aClone( aLstCpos[ nPos ] ) )

		end if

	next nX

return aRet

/*/{Protheus.doc} regSZ1
Registra no processamento o status e a mensagem de observação
@type function
@version  12.1.33
@author elton.alves
@since 25/03/2022
@param cStatus, character, satatus a ser registrado no processamento
@param cMensagem, character, Mensagem de observação a ser registrada no processamento
/*/
static function regSZ1( cStatus, cMensagem )

	RecLock( 'SZ1', .F. )

	SZ1->Z1_DATAPRC := Date()
	SZ1->Z1_HORAPRC := Time()
	SZ1->Z1_STATUS  := cStatus
	SZ1->Z1_OBSERV  := cMensagem

	SZ1->( MsUnlock() )

return
