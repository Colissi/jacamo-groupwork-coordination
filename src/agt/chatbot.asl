{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }


/* Initial beliefs and rules */

/* Initial goals */

/* Plans */

+!setup(Nome): true	<-
	// Create Workspace Artifact
	//.concat("workspace_", Nome, "_Chatbot", WName);
	//createWorkspace(WName);
	//joinWorkspace(WName, WOrg);
	//.concat("controle_", Nome, "_Chatbot", ArtName);
	//makeArtifact(ArtName, "board.Group", [], OrgArtId)[wid(WOrg)];
	//focus(OrgArtId)[wid(WOrg)];
	!answer("Grupo inicializado");
	inicializa(Nome);
.

+grupo(start(Manager,Grupo)): true <-
	!createManager;
.

+!createManager: 
	grupo(start(Manager,Grupo)) & 
	projeto(Projeto) & 
	descricao(Objetivo)
	<-
	.create_agent(Manager, "manager.asl");
	// Envia Crenças pro Gerente
	.send(Manager, tell, start(Grupo, Projeto, Objetivo));
	// Inicializa o Gerente
	.send(Manager, achieve, setup);
	+grupoStatus(Manager);
.

// Lida com as requisições do Dialogflow

+request(ResponseId, IntentName, Params, Contexts): true <-
	.print("Recebido request ",IntentName," do Dialog");
	!getNameByParam(Params, Name);
	systemLog(IntentName, Name);
	!responder(ResponseId, IntentName, Params, Contexts);
.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  
// PERGUNTAR COM ALTERNATIVA - COMANDOS
// 
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Comandos

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Comandos") 
	<-
	!getNameByParam(Params, Name);
	!comandos(Name);
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Resposta Comandos")
	<-
	!getNameByParam(Params, Nome);
	!getOpByParam(Params, Operacao);
	!executar(Nome, Operacao);
.

// Comandos Administradores

+!comandos(Nome):  
	.substring("admin", Nome) & 
	grupoStatus(_)
	<-
	contextBuilder("respostaComandosContext", Contexto);
	!answer("0. Cancelar<br>1. Grupos<br>2. Logs<br>3. Produtividade dos integrantes", Contexto);
.

// Grupos não inicializados
+!comandos(Nome):  
	.substring("admin", Nome)
	<-
	!answer("Esperando inicializção do sistema");
.

+!executar(Nome, Operacao):
	.substring("admin", Nome) & 
	Operacao == 0 &
	grupoStatus(_)
	<-
	!answer("Operação cancelada");
.

+!executar(Nome, Operacao):
	.substring("admin", Nome) & 
	Operacao == 1 &
	grupoStatus(_)
	<-
	// Mostrar Grupos
	mostraGrupos(Resposta);
	contextBuilder("selecionarGrupoContext", Contexto);
	!answer(Resposta, Contexto);
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Selecionar Grupo")
	<-
	!getOpByParam(Params, Operacao);
	!mostraGrupo(Operacao);
.

+!mostraGrupo(Operacao): true <-
	pegarGrupo(Operacao, Manager);
	.send(Manager, achieve, getGroupRoles);
.

+!executar(Nome, Operacao):
	.substring("admin", Nome) & 
	Operacao == 2 &
	grupoStatus(_)
	<-
	// Logs
	mostraGrupos(Resposta);
	contextBuilder("selecionarGrupoLogContext", Contexto);
	!answer(Resposta, Contexto);
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Selecionar Grupo Log")
	<-
	!getOpByParam(Params, Operacao);
	!mostraGrupoLog(Operacao);
.

+!mostraGrupoLog(Operacao): true <-
	pegarGrupo(Operacao, Manager);
	.send(Manager, achieve, getLog);
.

+!executar(Nome, Operacao):
	.substring("admin", Nome) & 
	Operacao == 3 &
	grupoStatus(_)
	<-
	// Produtividade
	mostraGrupos(Resposta);
	contextBuilder("selecionarGrupoProdutividadeContext", Contexto);
	!answer(Resposta, Contexto);
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Selecionar Grupo Produtividade")
	<-
	!getOpByParam(Params, Operacao);
	!mostraGrupoProdutividade(Operacao);
.

+!mostraGrupoProdutividade(Operacao): true <-
	pegarGrupo(Operacao, Manager);
	.send(Manager, achieve, getProdutividade);
.

+!executar(Nome, Operacao):
	.substring("admin", Nome) &
	grupoStatus(_)
	<-
	!answer("Operação inválida");
.

// Inicializa dinamicamente os agentes

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Criar Grupo") 
	<-
	!getNameByParam(Params, Nome);
	!criarGrupos(Nome);
.

+!criarGrupos(Nome):
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	!answer("Grupo já foi inicializado");
.

+!criarGrupos(Nome):
	.substring("manager", Nome)
	<-
	!setup(Nome);
.

+!criarGrupos(Nome):
	not .substring("manager", Nome)
	<-
	!answer("Isso não é o que você procura");
.

// Comandos Gerentes

+!comandos(Nome):
	.substring("manager", Nome) & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	contextBuilder("respostaComandosContext", Contexto);
	!answer("0. Cancelar<br>1. Tarefas<br>2. Grupo<br>3. Log<br>4. Produtividade dos integrantes", Contexto);
.

// Grupos não inicializados
+!comandos(Nome):
	.substring("manager", Nome)
	<-
	contextBuilder("respostaComandosContext", Contexto);
	!answer("0. Cancelar<br>1. Criar grupo", Contexto);
.

+!executar(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 0
	<-
	!answer("Operação cancelada");
.

+!executar(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 1 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	contextBuilder("respostaComandosTarefasContext", Contexto);
	!answer("0. Cancelar<br>1. Cadastrar tarefa<br>2. Remover tarefa<br>3. Listar tarefas<br>4. Tarefas não sendo realizadas<br>5. Tarefas não concluídas", Contexto);
.

+!executar(Nome, Operacao):
	.substring("manager", Nome) & 
	Operacao == 1
	<-
	// Criar Grupo
	!setup(Nome);
.

+!executar(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 2 & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	contextBuilder("respostaComandosGrupoContext", Contexto);
	!answer("0. Cancelar<br>1. Integrantes do grupo<br>2. Listar data de entrega das tarefas<br>3. Remover integrante<br>4. Marcar projeto como concluído", Contexto);
.

+!executar(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 3 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.send(Nome, achieve, getLog);
.

+!executar(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 4 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.send(Nome, achieve, getProdutividade);
.

+!executar(Nome, Operacao):
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	!answer("Operação inválida");
.

+!executar(Nome, Operacao):
	.substring("manager", Nome)
	<-
	!answer("Esperando inicialização do sistema");
.

// Comandos usuário

+!comandos(Nome): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	contextBuilder("respostaComandosContext", Contexto);
	!answer("0. Cancelar<br>1. Tarefas<br>2. Minhas tarefas<br>3. Grupo", Contexto);
.

+!comandos(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!executar(Nome, Operacao):
	Operacao == 0 &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Operação cancelada")
.

+!executar(Nome, Operacao):
	Operacao == 1 &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	contextBuilder("respostaComandosTarefasContext", Contexto);
	!answer("0. Cancelar<br>1. Listar tarefas cadastradas<br>2. Selecionar tarefa<br>3. Listar tarefas não concluídas", Contexto);
.

+!executar(Nome, Operacao):
	Operacao == 2 &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	contextBuilder("respostaComandosMinhasTarefasContext", Contexto);
	!answer("0. Cancelar<br>1. Tarefa em progresso<br>2. Marcar tarefa como concluída<br>3. Liberar tarefa<br>4. Data de entrega da tarefa<br>5. Quanto falta para a entrega da tarefa", Contexto);
.

+!executar(Nome, Operacao):
	Operacao == 3 &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	contextBuilder("respostaComandosGrupoContext", Contexto);
	!answer("0. Cancelar<br>1. Integrantes do grupo<br>2. Situação do projeto (concluído ou não concluído)", Contexto);
.

+!executar(Nome, Operacao): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes) 
	<-
	!answer("Operação inválida");
.

+!executar(Nome, Operacao): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Resposta Comandos Tarefas")
	<-
	!getNameByParam(Params, Nome);
	!getOpByParam(Params, Operacao);
	!executarTarefas(Nome, Operacao);
.

// Gerentes

+!executarTarefas(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 0 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	!answer("Operação cancelada");
.

+!executarTarefas(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 1 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Criar Tarefa
	contextBuilder("criarTarefaContext", Contexto);
	!answer("Insira uma descrição da tarefa: ", Contexto);
.

+!executarTarefas(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 2 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Remover Tarefa
	.send(Nome, achieve, tasksToRemove);
.

+!executarTarefas(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 3 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Tarefas
	.send(Nome, achieve, getTasks);
.

+!executarTarefas(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 4 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-	
	// Tarefas disponíveis
	.send(Nome, achieve, availableTasks(Nome));
.

+!executarTarefas(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 5 &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Tarefas pendentes
	.send(Nome, achieve, pendingTasks);
.

+!executarTarefas(Nome, Operacao):
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	!answer("Operação inválida");
.

// Usuários

+!executarTarefas(Nome, Operacao):
	Operacao == 0 &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-	
	!answer("Operação cancelada");
.

+!executarTarefas(Nome, Operacao):
	Operacao == 1 &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-	
	// Tarefas
	.send(Nome, achieve, getTasks);
.

+!executarTarefas(Nome, Operacao):
	Operacao == 2 &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Selecionar tarefa
	.send(Nome, achieve, availableTasks(Nome));
.

+!executarSelecionarTarefa(Resultado): 
	(Resultado == "Nenhuma tarefa foi cadastrada") |
	(Resultado == "Todas as tarefas já estão atribuídas")
	<-
	!answer(Resultado);
.

+!executarSelecionarTarefa(Resultado): true <-
	contextBuilder("selecionarTarefaContext", Contexto);
	!answer(Resultado, Contexto);
.

+!executarTarefas(Nome, Operacao):
	Operacao == 3 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Tarefas pendentes
	.send(Nome, achieve, pendingTasks);
.

+!executarTarefas(Nome, Operacao): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Operação inválida");
.

+!executarTarefas(Nome, Operacao): true <-
	!answer("Algo de errado aconteceu");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Resposta Comandos Minhas Tarefas")
	<-
	!getNameByParam(Params, Nome);
	!getOpByParam(Params, Operacao);
	!executarMinhasTarefas(Nome, Operacao);
.

// Usuário

+!executarMinhasTarefas(Nome, Operacao):
	Operacao == 0 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Operação cancelada");
.

+!executarMinhasTarefas(Nome, Operacao):
	Operacao == 1 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Tarefa em progresso
	.send(Nome, achieve, activeTask(Nome));
.

+!executarMinhasTarefas(Nome, Operacao):
	Operacao == 2 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Marcar tarefa como concluída
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, reqDevelopment(DataAtual, Hora));
.

+!executarMinhasTarefas(Nome, Operacao):
	Operacao == 3 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Liberar tarefa
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, dropTask(DataAtual, Hora, Nome));
.

+!executarMinhasTarefas(Nome, Operacao):
	Operacao == 4 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Data de entrega da tarefa
	.send(Nome, achieve, getTaskDate(Nome));
.

+!executarMinhasTarefas(Nome, Operacao):
	Operacao == 5 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Quanto falta para a entrega da tarefa
	.send(Nome, achieve, getDeliveryDate(Nome));
.

+!executarMinhasTarefas(Nome, Operacao): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Operação inválida");
.

+!executarMinhasTarefas(Nome, Operacao): true <-
	!answer("Algo de errado aconteceu");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Resposta Comandos Grupo")
	<-
	!getNameByParam(Params, Nome);
	!getOpByParam(Params, Operacao);
	!executarGrupo(Nome, Operacao);
.

// Gerente

+!executarGrupo(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 0 & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	!answer("Operação cancelada");
.

+!executarGrupo(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 1 & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Integrantes do grupo
	.send(Nome, achieve, getGroupRoles);
.

+!executarGrupo(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 2 & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Data de entrega da tarefa
	.send(Nome, achieve, getTaskDate(Nome));
.

+!executarGrupo(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 3 & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Remover agente
	.send(Nome, achieve, agentsToRemove);
.

+!executarGrupo(Nome, Operacao):
	.substring("manager", Nome) &
	Operacao == 4 & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Marcar projeto como concluído
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, completed(DataAtual, Hora));
.

+!executarRemoverAgente(Resultado): true <-
	contextBuilder("removerAgenteContext", Contexto);
	!answer(Resultado, Contexto);
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Remover Agente")
	<-
	!getNameByParam(Params, Nome);
	!getOpByParam(Params, Operacao);
	!removerAgente(Nome, Operacao);
.

+!removerAgente(Nome, Operacao):
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, removeAgent(Nome, DataAtual, Hora, Operacao));
.

// Usuário

+!executarGrupo(Nome, Operacao):
	Operacao == 0 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Operação cancelada");
.

+!executarGrupo(Nome, Operacao):
	Operacao == 1 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Integrantes do grupo
	.send(Nome, achieve, getGroupRoles);
.

+!executarGrupo(Nome, Operacao):
	Operacao == 2 & 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	// Situação do projeto (concluído ou não concluído)
	.send(Nome, achieve, isCompleted);
.

+!executarGrupo(Nome, Operacao): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Operação inválida");
.

+!executarGrupo(Nome, Operacao): true <-
	!answer("Algo de errado aconteceu");
.

/* Requisição de ajuda

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Me ajuda") & 
	not .substring("manager", Nome) & not .substring("manager", Nome) 
	& grupoStatus(_,Estado) & Estado <-
	.send(Nome, achieve, helpMe(Mensagem));
.
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  
// PERGUNTAR FIXAS "QUAL É O GRUPO?"
// 
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Perguntas a serem respondidas

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Grupo")
	<-
	!getNameByParam(Params, Nome);
	!estaticoGrupo(Nome);
.

+!estaticoGrupo(Nome): 
	.substring("admin", Nome) &
	grupoStatus(_)
	<-
	// Mostrar Grupos
	mostraGrupos(Resposta);
	contextBuilder("selecionarGrupoContext", Contexto);
	!answer(Resposta, Contexto);
.

+!estaticoGrupo(Nome): 
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	contextBuilder("respostaComandosGrupoContext", Contexto);
	!answer("0. Cancelar<br>1. Integrantes do grupo<br>2. Listar data de entrega das tarefas<br>3. Remover integrante<br>4. Marcar projeto como concluído", Contexto);
.

+!estaticoGrupo(Nome): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	contextBuilder("respostaComandosGrupoContext", Contexto);
	!answer("0. Cancelar<br>1. Integrantes do grupo<br>2. Situação do projeto (concluído ou não concluído)", Contexto);
.

+!estaticoGrupo(Nome): true	<-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Ultima Atualizacao")
	<-
	!getNameByParam(Params, Nome);
	!estaticoAtt(Nome);
.

+!estaticoAtt(Nome): 
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.send(Nome, achieve, getLastUpdate);
.

+!estaticoAtt(Nome): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	.send(Nome, achieve, getLastUpdate);
.

+!estaticoAtt(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Objetivo") 
	<-
	!getNameByParam(Params, Nome);
	!estaticoObj(Nome);
.

+!estaticoObj(Nome): 
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Objetivo do grupo
	.send(Nome, achieve, getObjective);
.

+!estaticoObj(Nome):
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes) 
	<-
	.send(Nome, achieve, getObjective);
.

+!estaticoObj(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Data Entrega")
	<-
	!getNameByParam(Params, Nome);
	!estaticoData(Nome);
.

+!estaticoData(Nome): 
	.substring("manager", Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Data tarefa
	.send(Nome, achieve, getTaskDate(Nome));
.

+!estaticoData(Data): 
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	.send(Nome, achieve, getTaskDate(Nome));
.

+!estaticoData(Data): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Diferenca Data Entrega")
	<-
	!getNameByParam(Params, Nome);
	!estaticoDifData(Nome);
.

//+!estaticoDifData(Nome): 
//	.substring("manager", Nome) &
//	.term2string(Agente, Nome) &
//	grupoStatus(Agente)
//	<-
//	// Diferença data
//	.send(Nome, achieve, getDeliveryDate(Nome));
//.

+!estaticoDifData(Nome):
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	.send(Nome, achieve, getDeliveryDate(Nome));
.

+!estaticoDifData(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Tarefas")
	<-
	!getNameByParam(Params, Nome);
	!estaticoTarefas(Nome);
.

+!estaticoTarefas(Nome):
	.substring("manager",Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	contextBuilder("respostaComandosTarefasContext", Contexto);
	!answer("0. Cancelar<br>1. Criar tarefa<br>2. Remover tarefa<br>3. Listar tarefas<br>4. Tarefas não sendo realizadas<br>5. Tarefas não concluídas<br>", Contexto);
.

+!estaticoTarefas(Nome):
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	contextBuilder("respostaComandosTarefasContext", Contexto);
	!answer("0. Cancelar<br>1. Listar tarefas cadastradas<br>2. Selecionar tarefa<br>3. Listar tarefas não concluídas", Contexto);
.

+!estaticoTarefas(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Minhas Tarefas")
	<-
	!getNameByParam(Params, Nome);
	!estaticoMinhasTarefas(Nome);
.

+!estaticoMinhasTarefas(Nome):
	not .substring("admin", Nome) &
	not .substring("manager", Nome) &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	contextBuilder("respostaComandosMinhasTarefasContext", Contexto);
	!answer("0. Cancelar<br>1. Tarefa em progresso<br>2. Marcar tarefa como concluída<br>3. Liberar tarefa<br>4. Data de entrega da tarefa<br>5. Quanto falta para a entrega da tarefa", Contexto);
.

+!estaticoMinhasTarefas(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Log")
	<-
	!getNameByParam(Params, Nome);
	!estaticoLog(Nome);
.

+!estaticoLog(Nome):
	.substring("admin",Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Logs
	mostraGrupos(Resposta);
	contextBuilder("selecionarGrupoLogContext", Contexto);
	!answer(Resposta, Contexto);
.

+!estaticoLog(Nome):
	.substring("manager",Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.send(Nome, achieve, getLog);
.

+!estaticoLog(Nome):
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Isso não é o que você procura");
.

+!estaticoLog(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Produtividade")
	<-
	!getNameByParam(Params, Nome);
	!estaticoProdutividade(Nome);
.

+!estaticoProdutividade(Nome):
	.substring("admin",Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	// Logs
	mostraGrupos(Resposta);
	contextBuilder("selecionarGrupoProdutividadeContext", Contexto);
	!answer(Resposta, Contexto);
.

+!estaticoProdutividade(Nome):
	.substring("manager",Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.send(Nome, achieve, getProdutividade);
.

+!estaticoProdutividade(Nome):
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	!answer("Isso não é o que você procura");
.

+!estaticoProdutividade(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Projeto")
	<-
	!getNameByParam(Params, Nome);
	!estaticoProjeto(Nome);
.

+!estaticoProjeto(Nome):
	not .substring("admin", Nome) &
	not .substring("manager", Nome) &
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes)
	<-
	.send(Nome, achieve, isCompleted);
.

+!estaticoProjeto(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Projeto Concluido")
	<-
	!getNameByParam(Params, Nome);
	!estaticoProjetoConcluido(Nome);
.

+!estaticoProjetoConcluido(Nome):
	.substring("manager",Nome) &
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, completed(DataAtual, Hora));
.

+!estaticoProjetoConcluido(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

/* Resposta Requisição de ajuda
 
+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Precisa Ajuda") & 
	.substring("manager", Nome) & 
	grupoStatus(_,Estado) & Estado 
	<-
	.send(Nome, achieve, needHelp);
.
*/

// Inicializa tarefa dinamicamente

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Criar Tarefa") 
	<-
	!getNameByParam(Params, Nome);
	!criarTarefa(Params, Nome);
.

+!criarTarefa(Params, Nome):
	.substring("manager", Nome) & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<- 
	!getTaskByParam(Params, Tarefa);
	!getDateByParam(Params, DataTarefa);
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, createTask(DataAtual, Hora, Tarefa, DataTarefa));
.

+!criarTarefa(Params, Nome):
	not .substring("manager", Nome)
	<- 
	!answer("Isso não é o que você procura");
.

+!criarTarefa(Params, Nome): true
	<- 
	!answer("Esperando inicialização do sistema");
.

// Seleciona tarefa dinamicamente

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Selecionar Tarefa")
	<-
	!getNameByParam(Params, Nome);
	!getOpByParam(Params, Operacao);
	!selecionarTarefa(Nome, Operacao);
.

+!selecionarTarefa(Nome, Operacao):
	.substring("manager", Nome) & 
	.term2string(Agente, Nome) &
	grupoStatus(Agente)
	<-
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, removeTask(Nome, DataAtual, Hora, Operacao));
.

+!selecionarTarefa(Nome, Operacao):
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes) &
	not .substring("manager", Nome) & 
	not .substring("admin", Nome)
	<-
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, DataAtual);
	.time(H,Min,S);
	.concat(H, ":", Min, ":", S, Hora);
	.send(Nome, achieve, assignTask(DataAtual, Hora, Nome, Operacao));
.

+!selecionarTarefa(Nome, Operacao): 
	.substring("manager", Nome) | 
	.substring("admin", Nome)
	<- 
	!answer("Comando para usuários");
.

+!selecionarTarefa(Nome, Operacao): true <- 
	!answer("Esperando inicialização do sistema");
.

// Término de tarefas

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Desenvolvimento")
	<-
	!getNameByParam(Params, Nome);
	!desenvolvimento(Nome);
.

+!desenvolvimento(Nome):
	.all_names(L) &
	.term2string(L, Agentes) &
	.substring(Nome, Agentes) &
	not .substring("admin", Nome) & 
	not .substring("manager", Nome)
	<-
	.send(Nome, achieve, reqDevelopment);
.

+!desenvolvimento(Nome):
	not .substring("admin", Nome) & 
	not .substring("manager", Nome)
	<-
	!answer("Comando para usuários");
.

+!desenvolvimento(Nome): true <-
	!answer("Esperando inicialização do sistema");
.

+!responder(ResponseId, IntentName, Params, Contexts): 
	(IntentName == "Estatistica")
	<-
	!getNameByParam(Params, Nome);
	!estaticoEstatistica(Nome);
.

+!estaticoEstatistica(Nome):
	.substring("admin", Nome)
	<-
	!answer("Estatística gerada");
	systemStatistic;
.

+!estaticoEstatistica(Nome): true <-
	!answer("Comando para administradores");
.

// Resposta padrão

+!responder(ResponseId, IntentName, Params, Contexts): true <-
	reply("Desculpe, não reconheço essa intenção");
.

// Planos para responder ao chatbot

+!answer(Resposta): true <-
	reply(Resposta);
.

+!answer(Resposta, Contexto): true <-
	reply(Resposta, Contexto);
.

// Printar contexto

+!printContexts([]).
+!printContexts([Context|List]): true <-
	.print(Context);
	!printContexts(List);
.

// Printar parâmetro

+!printParameters([]).
+!printParameters([Param|List]): true <-
	.print(Param)
	!printParameters(List)
.

// Receber parâmetro nome

+!getNameByParam([], Name) <- 
	Name = "Parâmetro nome não encontrado";
.

+!getNameByParam([param(Key,Value)|ParamsList], Name): (Key == "nome") <-
	Name = Value;
.

+!getNameByParam([param(Key,Value)|ParamsList], Name): (Key \== "nome") <-
	!getNameByParam(ParamsList, Name);
.

// Receber parâmetro operacao

+!getOpByParam([], Operation) <- 
	Operation = "Parâmetro operação não encontrado";
.

+!getOpByParam([param(Key,Value)|ParamsList], Operation): (Key == "operacao") <-
	Operation = Value;
.

+!getOpByParam([param(Key,Value)|ParamsList], Operation): (Key \== "operacao") <-
	!getOpByParam(ParamsList, Operation);
.

// Receber parâmetro tarefa

+!getTaskByParam([], Task) <- 
	Task = "Parâmetro tarefa não encontrado";
.

+!getTaskByParam([param(Key,Value)|ParamsList], Task): (Key == "tarefa") <-
	Task = Value;
.

+!getTaskByParam([param(Key,Value)|ParamsList], Task): (Key \== "tarefa") <-
	!getTaskByParam(ParamsList, Task);
.

// Receber parâmetro data

+!getDateByParam([], Date) <- 
	Date = "Parâmetro data não encontrado";
.

+!getDateByParam([param(Key,Value)|ParamsList], Date): (Key == "data") <-
	Date = Value;
.

+!getDateByParam([param(Key,Value)|ParamsList], Date): (Key \== "data") <-
	!getDateByParam(ParamsList, Date);
.

// Update Log

+!log(Log, Nome): true <-
	updateLog(Log, Nome);
.


