{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
//{ include("organisational.asl") }


/* Initial beliefs and rules */
ultimaTarefaCompleta("Nenhuma tarefa completada").
ultimoUpdate("Nenhum update realizado").
//ajuda("", "Nenhuma ajuda solicitada").

/* Initial goals */

/* Plans */

+!setup: 
	.my_name(Nome) &
	start(Agentes,Projeto,_)	 
	<-
	// Create Workspace Artifact
	.concat("workspace_", Nome, WName);
	createWorkspace(WName);
	joinWorkspace(WName, WOrg);
	.length(Agentes, Ag);
	.concat("tarefa_", Nome, ArtName);
	makeArtifact(ArtName, "board.Tasks", [Ag], OrgArtId)[wid(WOrg)];
	focus(OrgArtId)[wid(WOrg)];
	// Create Org Group
	//joinWorkspace(groupOrg, GrOrgId);
	joinWorkspace(Nome, GrOrgId);
	.concat("time_", Nome, GroupName);
	//createGroup(GroupName, team, GrArtId)[artifact_name(groupOrg), wid(GrOrgId)];
	createGroup(GroupName, team, GrArtId)[artifact_name(Nome), wid(GrOrgId)];
	//debug(inspector_gui(on))[artifact_id(GrArtId)];
	adoptRole(managerRole)[artifact_id(GrArtId)];
	focus(GrArtId)[wid(GrOrgId)];
	!createAgents;
.

+!createAgents:
	.my_name(Nome) & 
	start(Agentes,_,_) & 
	qtdAgentes(QtdAgentes) & QtdAgentes > 0 
	<-
	.nth(QtdAgentes-1, Agentes, Agente);
	//Criação dos agentes
	.create_agent(Agente, "generic.asl");
	// Atribuindo Roles aos agentes e focando os mesmos no Grupo, Workspace e Esquema
	.concat("tarefa_", Nome, ArtName);
	.concat("time_", Nome, GroupName);
	.send(Agente, achieve, setup(ArtName, GroupName));
	descontaAgentes;
	!createAgents;
.

+!createAgents: 
	.my_name(Nome) & 
	qtdAgentes(QtdAgentes) & QtdAgentes == 0 
	<-
	// Create the scheme
	//lookupArtifact(groupOrg, GrOrgId);
	lookupArtifact(Nome, GrOrgId);
	.concat("esquema_", Nome, Scheme);
	createScheme(Scheme, taskScheme, SchArtId)[wid(GrOrgId)];
  	//debug(inspector_gui(on))[artifact_id(SchArtId)];
  	focus(SchArtId)[wid(GrOrgId)];
	.concat("time_", Nome, GroupName);
  	lookupArtifact(GroupName, GrArtId);
  	// Garantir a espera do grupo estar bem formado
	?formationStatus(ok)[artifact_id(GrArtId)];
	addScheme(Scheme)[artifact_id(GrArtId)];
	resetaAgentes;
	!assignMissions;
.

+!assignMissions: 
	.my_name(Nome) &
	start(Agentes,_,_) & 
	qtdAgentes(QtdAgentes) & QtdAgentes > 0 
	<-
	// Atribuindo Missões para os agentes
	.nth(QtdAgentes-1, Agentes, Agente);
	.concat("esquema_", Nome, Scheme);
	.send(Agente, achieve, setMission(Scheme));
	descontaAgentes;
	!assignMissions;
.

+!assignMissions: qtdAgentes(QtdAgentes) & QtdAgentes == 0 <-
	.findall(Goal, specification(scheme_specification(taskScheme,goal(_,_,_,_,_,_,plan(_,Goal)),_,_)), Goals);
	.term2string(Goals, Objetivos);
	missoesMoise(Objetivos);
	resetaAgentes;
.

// Log

+!getLog: true <-
	pegarLog(Resultado);
	!appendLog(Resultado);
.

+!appendLog(Log):
	.my_name(Nome) &
	(Log \== "Nenhuma operação foi realizada no sistema")
	<-
	.send(chatbot, achieve, log(Log, Nome));
	.send(chatbot, achieve, answer(Log));
.

+!appendLog(Log): true <-
	.send(chatbot, achieve, answer(Log));
.

// Produtividade

+!getProdutividade: true <-
	pegarProdutividade(Resultado);
	.send(chatbot, achieve, answer(Resultado));
.

// Projeto completo

+!completed(DataAtual, Hora): .my_name(Nome) <-
	concluido(Nome, DataAtual, Hora, Resultado);
	.send(chatbot, achieve, answer(Resultado));
.

+!isCompleted: 
	fazer_desenvolvimento(Estado) &
	Estado
	<-
	.send(chatbot, achieve, answer("Projeto concluído, obrigado por utilizar o sistema"));
.

+!isCompleted: 
	fazer_desenvolvimento(Estado) &
	not Estado
	<-
	!pendingTasks;
.

// Cria tarefa dinamicamente

+!createTask(DataAtual, Hora, Tarefa, DataTarefa): .my_name(Nome) <-
	criarTarefa(Nome, DataAtual, Hora, Tarefa, DataTarefa);
	.send(chatbot, achieve, answer("Tarefa adicionada"));
.

// Remover tarefa

+!tasksToRemove: true <-
	tarefasDisponiveis(Tarefas);
	if (Tarefas == "Nenhuma tarefa foi cadastrada") {
		.send(chatbot, achieve, executarSelecionarTarefa(Tarefas));
	} else {
		.concat("0. Cancelar<br>", Tarefas, Resposta);
		.send(chatbot, achieve, executarSelecionarTarefa(Resposta));	
	}
.

+!removeTask(Nome, DataAtual, Hora, Tarefa): true <-
	removerTarefa(Nome, DataAtual, Hora, Tarefa, Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

// Remover usuário

+!agentsToRemove: true <-
	.findall(r(Nome,Role), play(Nome,Role,Grupo), L);
	.term2string(L, Nomes);
	retornaNomeExclusao(Nomes, Resposta);
	.send(chatbot, achieve, executarRemoverAgente(Resposta));
.

+!removeAgent(AgReq, DataAtual, Hora, Agente): true <-
	.findall(r(Nome,Role), play(Nome,Role,Grupo), L);
	.term2string(L, Nomes);
	removerAgente(Nomes, AgReq, DataAtual, Hora, Agente, Resposta);
	!remover(Resposta);
.

+!remover(Resposta): (Resposta == "Operação cancelada")	<-
	.send(chatbot, achieve, answer(Resposta));
.

+!remover(Resposta): true <-
	.kill_agent(Resposta);
	.send(chatbot, achieve, answer("USUÁRIO REMOVIDO"));
.

// Planos de questões a serem respondidas

+!availableTasks(Nome): 
	.my_name(Ag) &
	.term2string(Ag, Agente) &
	(Nome == Agente) 
	<-
	tarefasDisponiveis(Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

+!availableTasks(Nome): 
	.my_name(Ag) &
	.term2string(Ag, Agente) &
	(Nome \== Agente)
	<-
	tarefasDisponiveis(Resposta);
	.send(chatbot, achieve, executarSelecionarTarefa(Resposta));
.

+!getGroupRoles: true <-
	// L é a lista de nomes
	.findall(r(Nome,Role), play(Nome,Role,Grupo), L);
	.term2string(L, Nomes);
	retornaNome(Nomes, Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

+!getLastUpdate: true <-
	?ultimoUpdate(Data);
	?ultimaTarefaCompleta(Tarefa);
	.concat("[", Data, "]", ": ", Tarefa, Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

+!getObjective: start(_,_,Objetivo) <-
	.concat("Objetivo do grupo é: ", Objetivo, ObjetivoGrupo);
	.send(chatbot, achieve, answer(ObjetivoGrupo));
.

+!getTaskDate(Nome): true <-
	dataTarefa(Nome, Data);
	.send(chatbot, achieve, answer(Data));
.

+!getDeliveryDate(Nome): true <-
	.date(Y,M,D);
	.concat(D, "/", M, "/", Y, Data);
	deliveryDate(Nome, Data, Resultado);
	.send(chatbot, achieve, answer(Resultado));
.

+!getTasks: true <-
	tarefas(Resultado);
	.send(chatbot, achieve, answer(Resultado));
.

+!activeTask(Nome): true <-
	minhaTarefa(Nome, Resultado);
	.send(chatbot, achieve, answer(Resultado));
.

+!pendingTasks: true <-
	tarefasPendentes(Resultado);
	.send(chatbot, achieve, answer(Resultado));
.
/*
+!needHelp: true <-
	// L é a lista de agentes que necessitam de ajuda
	.findall(r(Nome,Mensagem), ajuda(Nome,Mensagem), L);
	.term2string(L, Nomes);
	precisamAjuda(Nomes, Resposta);
	.send(chatbot, achieve, answer(Resposta));
. 
*/