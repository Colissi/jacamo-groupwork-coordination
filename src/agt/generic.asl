{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
//{ include("organisational.asl") }


/* Initial beliefs and rules */

/* Initial goals */

/* Plans */

+!setup(OrgArt, GrArt)[source(Nome)] <-
	// Workspace Artifact
	.concat("workspace_", Nome, WName);
	joinWorkspace(WName, WOrg);
	lookupArtifact(OrgArt, OrgArtId);
	focus(OrgArtId)[wid(WOrg)];
	// Group
	//joinWorkspace(groupOrg, GrOrgId);
	joinWorkspace(Nome, GrOrgId);
	lookupArtifact(GrArt, GrArtId);
	focus(GrArtId)[wid(GrOrgId)];
	adoptRole(userRole)[artifact_id(GrArtId)];
.

+!setMission(SchArt)[source(Nome)] <-
	lookupArtifact(SchArt, SchArtId);
	lookupArtifact(Nome, GrOrgId);
	focus(SchArtId)[wid(GrOrgId)];
	//commitMission(mission_tarefa_1)[artifact_id(SchArtId)];
.

// Selecionar tarefa dinamicamente

// Verificar se já está fazendo a missão
+!assignTask(DataAtual, Hora, Agente, Tarefa):
	.concat("mission_tarefa_", Tarefa, Missao) &
	.term2string(Ag, Agente) &
	.term2string(M, Missao) &
	commitment(Ag,M,_)
	<-
	.send(chatbot, achieve, answer("Já esá responsável por uma tarefa, por favor conclua a mesma."));
.

+!assignTask(DataAtual, Hora, Agente, Tarefa): true <- 
	.findall(Mission, specification(scheme_specification(taskScheme,_,Mission,_)), Missions);
	.term2string(Missions, Missoes);
	.concat("mission_tarefa_", Tarefa, Missao);
	missoes(Missao, Missoes, IsMission);
	!atribuiTarefa(DataAtual, Hora, Agente, Tarefa, IsMission);
.

// Adicionar nas missões
+!atribuiTarefa(DataAtual, Hora, Agente, Tarefa, IsMission): 
	play(Manager,managerRole,_) &
	IsMission 
	<-
	.concat("mission_tarefa_", Tarefa, Mission);
	.term2string(Missao, Mission);
	.concat("esquema_", Manager, Scheme);
	commitMission(Missao)[artifact_name(Scheme)];
	atribuirTarefa(DataAtual, Hora, Agente, Tarefa, Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

// Adicionar nas tarefas secundárias
+!atribuiTarefa(DataAtual, Hora, Agente, Tarefa, IsMission): 
	not IsMission 
	<-
	atribuirTarefa(DataAtual, Hora, Agente, Tarefa, Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

// Libera tarefa

// Liberar tarefa missão
+!dropTask(DataAtual, Hora, Nome):
	.term2string(Ag, Nome) &
	commitment(Ag,Mission,Scheme)
	<-
	leaveMission(Mission)[artifact_name(Scheme)];
	liberaTarefa(DataAtual, Hora, Nome, Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

// Liberar tarefa secundária
+!dropTask(DataAtual, Hora, Nome): true	<-
	liberaTarefa(DataAtual, Hora, Nome, Resposta);
	.send(chatbot, achieve, answer(Resposta));
.

/* Requisita ajuda
+!helpMe(Mensagem): .my_name(Agente) & play(Manager,managerRole,_) <-
	.send(Manager, tell, ajuda(Agente, Mensagem));
	.send(chatbot, achieve, answer("Pedido de ajuda solicitado"));
.
*/

+!attManagerBelief(Tarefa, Update): play(Manager,managerRole,_) <-
	.send(Manager, tell, ultimaTarefaCompleta(Tarefa));
	.send(Manager, tell, ultimoUpdate(Update));
.

// Planos de questões a serem respondidas

+!isCompleted: play(Manager,managerRole,_) <-
	.send(Manager, achieve, isCompleted);
.

+!getTasks: play(Manager,managerRole,_) <-
	.send(Manager, achieve, getTasks);
.

+!availableTasks(Nome): play(Manager,managerRole,_) <-
	.send(Manager, achieve, availableTasks(Nome));
.

+!getGroupRoles: play(Manager,managerRole,_) <-
	.send(Manager, achieve, getGroupRoles);
.

+!getLastUpdate: play(Manager,managerRole,_) <-
	.send(Manager, achieve, getLastUpdate);
.

+!getObjective: play(Manager,managerRole,_) <-
	.send(Manager, achieve, getObjective);
.

+!getTaskDate(Nome): play(Manager,managerRole,_) <-
	.send(Manager, achieve, getTaskDate(Nome));
.

+!getDeliveryDate(Nome): play(Manager,managerRole,_) <-
	.send(Manager, achieve, getDeliveryDate(Nome));
.

+!activeTask(Nome): play(Manager,managerRole,_) <-
	.send(Manager, achieve, activeTask(Nome));
.

+!pendingTasks: play(Manager,managerRole,_) <-
	.send(Manager, achieve, pendingTasks);
.

// Planos do Artefato

+!reqDevelopment(DataAtual, Hora): .my_name(Nome) & play(Nome,userRole,_) <-
	tarefaFinalizada(DataAtual, Hora, Nome, Objetivo, Tarefa, Resposta);
	verificaMissao(Objetivo, IsMission);
	!finalizarTarefa(DataAtual, Tarefa, Resposta, Objetivo, IsMission);
.

+!finalizarTarefa(DataAtual, Tarefa, Resposta, Objetivo, IsMission):
	(Resposta == "Nenhuma tarefa foi cadastrada") |
	(Resposta == "Não está responsável por alguma tarefa")
	<-
	.send(chatbot, achieve, answer(Resposta));
.

+!finalizarTarefa(DataAtual, Tarefa, Resposta, Objetivo, IsMission): 
	.my_name(Ag) &
	IsMission &
	play(Manager,managerRole,_) &
	commitment(Ag,_,_) &
	obligation(Ag,Norm,What,Deadline)[artifact_id(ArtId)]
	<-
	.concat("[", Nome, "]: ", Tarefa, Task);
	!attManagerBelief(Task, DataAtual);
	.concat("tarefa_", Objetivo, Go);
	.term2string(Goal, Go);
	goalAchieved(Goal)[artifact_id(ArtId)];
	//!Goal[scheme(Scheme)];
	.send(chatbot, achieve, answer("Bom trabalho!"));
.

+!finalizarTarefa(DataAtual, Tarefa, Resposta, Objetivo, IsMission): 
	.my_name(Nome) &
	not IsMission 
	<-
	.concat("[", Nome, "]: ", Tarefa, Task);
	!attManagerBelief(Task, DataAtual);
	.send(chatbot, achieve, answer("Bom trabalho!"));
.
