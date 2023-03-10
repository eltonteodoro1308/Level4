/*
Pós desenvolvimento:

	Melhorar a query
	manutenção horas úteis do mês pela apuração
	Tratar mês sem apontamento

*/
/*

Anotações Alex:

0 * Incluir data início e data fim no cadasro da tarefa. O recurso só poderá lançar horas dentro do intervalo cadastrado.
1 * Liste todos os apontamentos realizados no período
2 * Que permita ao clicar em um link para visualizar as horas lançadas
3 * Permita marcar uma flag de validado, para só assim esse apontamento possa se medido.
4 - A medição de apontamentos só deve rodar para apontamentos que estejam validados
5 - O limite de horas do mês se restringe ao contrato e não ao total de horas trabalhadas

*/

/*

* Colocar em um markbrowse a aprovação de lote de apontamento e deixar marcar o que estiver em aprovação.

* Mês para apontamento é o mês corrente e o mês anterior até o dia x do mês corrente

* Ajustar o cadastro de recursos para não permitir excluir apenas bloquear.

* Criar campo na CN9 ( CN9_XCDPMD ) para informar as condições de pagamentos do pedido de venda e de compra na medição automática

* Usar os campos CN9_XCNDPG na medição automática do contrato

* MX_APTOMES deverá definir o mês limite para apontamento e não mais o mês permitido para apontamento, SUBSTITUIDO PELO PARAMETRO MX_TOLDIAS

* Criar campo ZA_INICIO e ZA_FINAL indicando tempo de existência da tarefa para apontamento.

* Criar a tabela (SZC - Cabeçalho de apontamentos) com os campos:
	-> Código do Recurso
	-> Nome do Recurso
	-> Código da Tarefa
	-> Nome da Tarefa
	-> Mês/Ano Vigencia
	-> Total de Horas Apontadas
	-> Status:
		-> Em Apontamento
		-> Em Aprovação
		-> Aprovado
		-> Não Aprovado

* O browser da tabela ( SZC - Cabeçalho de apontamentos ) deverá tem dois cenários de chamada:

	-> Cenário de Manutenção: onde será permitido a inclusão, alteração, exclusão e visualização dos apontamentos do cabeçalho e também seu envio para aprovação, a inclusão do cabeçalho é limitada ao período de vigência da tarefa e até o mês corrente "lastday(date())", ao criar um cabeçalho os itens em grid devem ser gerados automaticamente correspondendo a cada dia do mês, repeitando o limite de vigência da tarefa.

	-> Cenário de aprovação: permite apenas visualizar, aprovar e rejeitar os apontamentos, exibir soma de horas

* Excluir e desconsiderar o campo CNA_XRTAPR

* Criar tabela ZY genérica com a quantidade de horas úteis do mês
	-> 01/2023 - 176 hrs
	-> 02/2023 - 132 hrs
	-> ...

* Criar campo CNB_XHREXT indicando valor da hora extra na apuração e tratar o valor da hora útil e extra nos seguintes cenários:
	-> Horas Planejadas == Horas Úteis
	-> Horas Planejadas <  Horas Úteis
	-> Horas Planejadas >  Horas Úteis
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
