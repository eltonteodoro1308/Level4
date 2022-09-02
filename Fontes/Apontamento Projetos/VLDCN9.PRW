#include 'totvs.ch'

user function vldCn9( cTipo )

	local lRet   := .F.
	local cAlias := getNextAlias()

	If Select(cAlias) <> 0
		
        (cAlias)->(DbCloseArea())
	
    EndIf

	BeginSql alias cAlias
    
        %NOPARSER%

        SELECT COUNT(*) COUNT FROM %TABLE:CN9% CN9 

        INNER JOIN %TABLE:CN1% CN1
        ON CN9.CN9_FILIAL = CN1.CN1_FILIAL
        AND CN9.CN9_TPCTO = CN1.CN1_CODIGO
        AND CN9.D_E_L_E_T_ = CN1.D_E_L_E_T_

        WHERE CN9.%NOTDEL%
        AND CN9.CN9_FILIAL = %XFILIAL:CN9%
        AND CN9.CN9_NUMERO = %EXP:&(READVAR())%
        AND CN9_SITUAC = '05'
        AND CN1.CN1_ESPCTR = %EXP:cTipo%
	
    EndSql

	lRet :=  (cAlias)->COUNT > 0

	(cAlias)->(DbCloseArea())

return lRet
