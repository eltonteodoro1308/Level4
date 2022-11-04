#include 'totvs.ch'

user function tstx3obgt()

	local aTabelas := {'SE1','SE2'}
	local nX       := 0
	local cSeekXb4 := ''
	local cHelp    := ''
	local cNomeTab := ''
	local cCsv     := 'TABELA;NOME TABELA;OBRIGATORIO;CAMPO;TIPO;TAMANHO;DECIMAL;TITULO;DESCRICAO;HELP' + CRLF

	rpcsetenv('99','01')

	SX3->( DbSetOrder( 1 ) )
	SX2->( DbSetOrder( 1 ) )
	DbUseArea( .T., 'TOPCONN', 'XB4', 'XB4', .T., .T. )
	XB4->( dbSetIndex( 'XB41' ) )
	XB4->( dbSetOrder( 1 ) )

	for nX := 1 to len( aTabelas )

		if SX3->( DbSeek( aTabelas[ nX ] ) )

			cNomeTab := SX2->( if( DbSeek( SX3->X3_ARQUIVO ) , X2_NOME, '' ) )

			while SX3->( aTabelas[ nX ] == X3_ARQUIVO .AND. ! EOF() )

				cSeekXb4 := ''
				cSeekXb4 += PadR( 'P' + SX3->X3_CAMPO, 30 ) + 'P'
				cSeekXb4 += 'pt-br'

				cHelp := XB4->( StrTran( if( DbSeek( cSeekXb4 ), XB4_HELP, '' ), CRLF, ' ' ) ) 

				cCsv += SX3->(;
					X3_ARQUIVO + ';' +;
					cNomeTab + ';' +;
					if( X3Obrigat( X3_CAMPO ), 'Sim', 'Não' ) + ';' + ;
					X3_CAMPO + ';' +;
					X3_TIPO + ';' +;
					cValToChar( X3_TAMANHO ) + ';' +;
					cValToChar( X3_DECIMAL ) + ';' +;
					X3_TITULO + ';' +;
					X3_DESCRIC + ';' + ;
					cHelp )  + CRLF

				SX3->( DbSkip() )

			end

		end if

	next nX

	MemoWrite( 'c:\temp\lista_campos.csv', cCsv )

return
