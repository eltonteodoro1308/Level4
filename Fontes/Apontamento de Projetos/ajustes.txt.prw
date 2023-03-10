/*
P�s desenvolvimento:

	Melhorar a query
	manuten��o horas �teis do m�s pela apura��o
	Tratar m�s sem apontamento

*/
/*

Anota��es Alex:

0 * Incluir data in�cio e data fim no cadasro da tarefa. O recurso s� poder� lan�ar horas dentro do intervalo cadastrado.
1 * Liste todos os apontamentos realizados no per�odo
2 * Que permita ao clicar em um link para visualizar as horas lan�adas
3 * Permita marcar uma flag de validado, para s� assim esse apontamento possa se medido.
4 - A medi��o de apontamentos s� deve rodar para apontamentos que estejam validados
5 - O limite de horas do m�s se restringe ao contrato e n�o ao total de horas trabalhadas

*/

/*

* Colocar em um markbrowse a aprova��o de lote de apontamento e deixar marcar o que estiver em aprova��o.

* M�s para apontamento � o m�s corrente e o m�s anterior at� o dia x do m�s corrente

* Ajustar o cadastro de recursos para n�o permitir excluir apenas bloquear.

* Criar campo na CN9 ( CN9_XCDPMD ) para informar as condi��es de pagamentos do pedido de venda e de compra na medi��o autom�tica

* Usar os campos CN9_XCNDPG na medi��o autom�tica do contrato

* MX_APTOMES dever� definir o m�s limite para apontamento e n�o mais o m�s permitido para apontamento, SUBSTITUIDO PELO PARAMETRO MX_TOLDIAS

* Criar campo ZA_INICIO e ZA_FINAL indicando tempo de exist�ncia da tarefa para apontamento.

* Criar a tabela (SZC - Cabe�alho de apontamentos) com os campos:
	-> C�digo do Recurso
	-> Nome do Recurso
	-> C�digo da Tarefa
	-> Nome da Tarefa
	-> M�s/Ano Vigencia
	-> Total de Horas Apontadas
	-> Status:
		-> Em Apontamento
		-> Em Aprova��o
		-> Aprovado
		-> N�o Aprovado

* O browser da tabela ( SZC - Cabe�alho de apontamentos ) dever� tem dois cen�rios de chamada:

	-> Cen�rio de Manuten��o: onde ser� permitido a inclus�o, altera��o, exclus�o e visualiza��o dos apontamentos do cabe�alho e tamb�m seu envio para aprova��o, a inclus�o do cabe�alho � limitada ao per�odo de vig�ncia da tarefa e at� o m�s corrente "lastday(date())", ao criar um cabe�alho os itens em grid devem ser gerados automaticamente correspondendo a cada dia do m�s, repeitando o limite de vig�ncia da tarefa.

	-> Cen�rio de aprova��o: permite apenas visualizar, aprovar e rejeitar os apontamentos, exibir soma de horas

* Excluir e desconsiderar o campo CNA_XRTAPR

* Criar tabela ZY gen�rica com a quantidade de horas �teis do m�s
	-> 01/2023 - 176 hrs
	-> 02/2023 - 132 hrs
	-> ...

* Criar campo CNB_XHREXT indicando valor da hora extra na apura��o e tratar o valor da hora �til e extra nos seguintes cen�rios:
	-> Horas Planejadas == Horas �teis
	-> Horas Planejadas <  Horas �teis
	-> Horas Planejadas >  Horas �teis
*/

user function calcula()

	jContrato := jsonObject():new()

	jContrato["HR_PLANEJADA"] := randomize(100,350)
	jContrato["HR_UTIL_MES"] := 176
	jContrato["HR_TRABALHADA"] := randomize(100,350)

//jContrato["VLR_NORMAL"]
//jContrato["VLR_EXTRA"]
//jContrato["HR_MED_PLANEJADA"] := 0
//jContrato["HR_MED_EXCED_VLR_NORMAL"] := 0
//jContrato["HR_MED_EXCED_VLR_EXTRA"] := 0

	if jContrato["HR_PLANEJADA"] >= jContrato["HR_UTIL_MES"]

		if jContrato["HR_PLANEJADA"] >= jContrato["HR_TRABALHADA"]

			jContrato["HR_MED_PLANEJADA"]        := jContrato["HR_TRABALHADA"]
			jContrato["HR_MED_EXCED_VLR_NORMAL"] := 0
			jContrato["HR_MED_EXCED_VLR_EXTRA"]  := 0

		else

			jContrato["HR_MED_PLANEJADA"]        := jContrato["HR_PLANEJADA"]
			jContrato["HR_MED_EXCED_VLR_NORMAL"] := 0
			jContrato["HR_MED_EXCED_VLR_EXTRA"]  := jContrato["HR_TRABALHADA"] - jContrato["HR_PLANEJADA"]

		end if

	elseif jContrato["HR_PLANEJADA"] < jContrato["HR_UTIL_MES"]

		if jContrato["HR_PLANEJADA"] >= jContrato["HR_TRABALHADA"]

			jContrato["HR_MED_PLANEJADA"]        := jContrato["HR_TRABALHADA"]
			jContrato["HR_MED_EXCED_VLR_NORMAL"] := 0
			jContrato["HR_MED_EXCED_VLR_EXTRA"]  := 0

		else

			if jContrato["HR_TRABALHADA"] <= jContrato["HR_UTIL_MES"]

				jContrato["HR_MED_PLANEJADA"]        := jContrato["HR_PLANEJADA"]
				jContrato["HR_MED_EXCED_VLR_NORMAL"] := jContrato["HR_TRABALHADA"] - jContrato["HR_PLANEJADA"]
				jContrato["HR_MED_EXCED_VLR_EXTRA"]  := 0

			else

				jContrato["HR_MED_PLANEJADA"]        := jContrato["HR_PLANEJADA"]
				jContrato["HR_MED_EXCED_VLR_NORMAL"] := jContrato["HR_UTIL_MES"] - jContrato["HR_PLANEJADA"]
				jContrato["HR_MED_EXCED_VLR_EXTRA"]  := jContrato["HR_TRABALHADA"] - jContrato["HR_UTIL_MES"]


			end if

		end if

	else

	end if

return

/*

Tipo de Contrato Horas Vendidas  => 002
Tipo de Planilha Horas Vendidas  => 002
Tipo de Contrato Horas Compradas => 004
Tipo de Planilha Horas Compradas => 004

   
*/
