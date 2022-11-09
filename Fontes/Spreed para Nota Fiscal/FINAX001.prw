#include 'totvs.ch'

user function FINAX001()

	Local cPrefDe   := ''
	Local cPrefAte  := ''
	local cNumDe    := ''
	local cNumAte   := ''
	local cParcDe   := ''
	local cParcAte  := ''
	local cTipoDe   := ''
	local cTipoAte  := ''
	local dEmissDe  := ''
	local dEmissAte := ''
    local cTes      := ''
    local cProduto  := ''
    local cCondPgto := ''

	if pergunte('FINAX001')

		cPrefDe   := MV_PAR01
		cPrefAte  := MV_PAR02
		cNumDe    := MV_PAR03
		cNumAte   := MV_PAR04
		cParcDe   := MV_PAR05
		cParcAte  := MV_PAR06
		cTipoDe   := MV_PAR07
		cTipoAte  := MV_PAR08
		dEmissDe  := MV_PAR09
		dEmissAte := MV_PAR10
        cProduto  := MV_PAR11
        cTes      := MV_PAR12
        cCondPgto := MV_PAR13

        /**
        
        */

	end if

return
