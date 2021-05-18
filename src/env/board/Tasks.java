// CArtAgO artifact code for project smartjason_integrado

package board;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.ibm.icu.impl.UResource.Array;

import cartago.*;

public class Tasks extends Artifact {
	
	private String log = "";
	
	private List<String> missoes = new ArrayList<String>();
	private List<String> tarefas = new ArrayList<String>();
	private List<String> dataTarefas = new ArrayList<String>();
 	private List<List<String>> responsavelTarefas = new ArrayList<List<String>>();
	private List<List<Boolean>> conclusaoTarefas = new ArrayList<List<Boolean>>();
	private List<String> produtividade = new ArrayList<String>();
	private List<String> agentesRemovidos = new ArrayList<String>();

	void init(int qtdAgentes) {
		defineObsProperty("qtdAgentes", qtdAgentes);
		defineObsProperty("resetaAgentes", qtdAgentes);
		
		defineObsProperty("fazer_desenvolvimento", false);
	}
	
	@OPERATION
	void pegarLog(OpFeedbackParam<String> resultado) {
		if (this.log == "")
			resultado.set("Nenhuma operação foi realizada no sistema");
		else
			resultado.set(this.log);
	}
	
	@OPERATION
	void missoesMoise(String missoes) {
		String regex = "\"(.*?)\"";
		Pattern p = Pattern.compile(regex);
		Matcher m = p.matcher(missoes);
		while (m.find()) {
			String tarefa = m.group().replaceAll("\"", "");
			if (!tarefa.equals("infinity")) {
				this.tarefas.add(tarefa);
				this.dataTarefas.add("02/10/2020");
				List<String> agentes = new ArrayList<String>();
				//agentes.add("");
				this.responsavelTarefas.add(agentes);
				List<Boolean> conclusao = new ArrayList<Boolean>();
				//conclusao.add(false);
				this.conclusaoTarefas.add(conclusao);
			}			
		}
	}
	
	@OPERATION
	void missoes(String missao, String missoes, OpFeedbackParam<Boolean> resultado) {
		String regex = "mission_tarefa_\\d+";
		Pattern p = Pattern.compile(regex);
		Matcher m = p.matcher(missoes);
		boolean flag = false;
		while (m.find()) {
			String mission = m.group();
			this.missoes.add(mission);
			if (mission.equals(missao))
				flag = true;
		}
		resultado.set(flag);
	}
	
	@OPERATION
	void verificaMissao(int missao, OpFeedbackParam<Boolean> resultado) {
		boolean flag = false;
		if (missao-1 <= this.missoes.size())
			flag = true;
		resultado.set(flag);
	}
	
	@OPERATION
	void pegarProdutividade(OpFeedbackParam<String> resultado) {
		String resposta = "";
		int qtdTarefas = this.tarefas.size();
		if (qtdTarefas == 0)
			resposta = "Nenhuma tarefa foi cadastrada";
		else {
			if (this.produtividade.size() == 0)
				resposta = "Não há produtividade no grupo - sem tarefas concluídas";
			else {
				for (int i = 0; i < this.produtividade.size(); i++) {
					String agente = this.produtividade.get(i);
					int occurrences = Collections.frequency(this.produtividade, agente);
					resposta += agente.replaceAll("_", " ").toUpperCase() + ": " + occurrences + "/" + qtdTarefas; 
				}
			}
		}
		resultado.set(resposta);
	}
	
	@OPERATION
	void nomeTarefa(int tarefa, OpFeedbackParam<String> resultado) {
		resultado.set(this.tarefas.get(tarefa));
	}
	
	@OPERATION
	void criarTarefa(String nome, String dataAtual, String hora, String tarefa, String dataTarefa) {
		// Log
		this.log += "[" + dataAtual + " " + hora + "] " + nome.replaceAll("_", " ").toUpperCase() + " - Adicionou tarefa: " + tarefa + "<br>";
		// Criar Tarefa
		this.tarefas.add(tarefa);
		this.dataTarefas.add(dataTarefa);
		List<String> agentes = new ArrayList<String>();
		//agentes.add("");
		this.responsavelTarefas.add(agentes);
		List<Boolean> conclusao = new ArrayList<Boolean>();
		//conclusao.add(false);
		this.conclusaoTarefas.add(conclusao);
	}
	
	@OPERATION
	void removerTarefa(String nome, String dataAtual, String hora, int tarefa, OpFeedbackParam<String> resultado) {
		String resposta = "";
		if (tarefa == 0) {
			resposta = "Operação cancelada";
		} else {
			// Remover Tarefa
			String task = this.tarefas.get(tarefa-1);
			this.tarefas.remove(tarefa-1);
			this.dataTarefas.remove(tarefa-1);
			this.responsavelTarefas.remove(tarefa-1);
			this.conclusaoTarefas.remove(tarefa-1);
			resposta = "Tarefa: " + task + " REMOVIDA";
			// Log
			this.log += "[" + dataAtual + " " + hora + "] " + nome.replaceAll("_", " ").toUpperCase() + " - Removeu tarefa: " + task + "<br>";
		}
		resultado.set(resposta);
	}
	
	@OPERATION
	void tarefas(OpFeedbackParam<String> resultado) {
		String resposta = "";
		if (this.tarefas.isEmpty())
			resposta = "Nenhuma tarefa foi cadastrada";
		else {
			for (int i = 0; i < this.tarefas.size(); i++)
				resposta += this.tarefas.get(i) + "<br>";
		}
		resultado.set(resposta);
	}
	
	@OPERATION
	void tarefasDisponiveis(OpFeedbackParam<String> resultado) {
		String resposta = "";
		if (this.tarefas.isEmpty())
			resposta = "Nenhuma tarefa foi cadastrada";
		else {
			for (int i = 0; i < this.tarefas.size(); i++) {
				resposta += (i+1) + ". "+ this.tarefas.get(i) + " - Entrega: " + this.dataTarefas.get(i) + "<br>";
			}
		}
		resultado.set(resposta);
	}
	
	@OPERATION
	void atribuirTarefa(String dataAtual, String hora, String agenteResponsavel, int tarefa, OpFeedbackParam<String> nomeAgente) {
		boolean flag = false;
		String resposta = "";
		for (int i = 0; i < this.responsavelTarefas.size(); i++) {
			List<String> agentes = this.responsavelTarefas.get(i);
			for (int j = 0; j < agentes.size(); j++) {
				if (agentes.get(j).equals(agenteResponsavel)) {
					flag = true;
					break;
				}
			}
		}
		if (flag)
			resposta = "Já está responsável por uma tarefa, por favor conclua a mesma.";
		else {
			// Atribuir Tarefa		
			int index = tarefa-1;
			List<String> agentes = new ArrayList<String>();
			agentes = this.responsavelTarefas.get(index);
			agentes.add(agenteResponsavel);
			List<Boolean> conclusao = new ArrayList<Boolean>();
			conclusao = this.conclusaoTarefas.get(index);
			conclusao.add(false);
			this.responsavelTarefas.set(index, agentes);
			this.conclusaoTarefas.set(index, conclusao);
			String ag = "[ ";
			for (int i = 0; i < agentes.size(); i++)
				ag += agentes.get(i).replaceAll("_", " ").toUpperCase() + " - ";
			ag = ag.substring(0, ag.length() - 2);
			ag += "] ";
			String task = this.tarefas.get(index);
			task = task.replaceFirst("\\[(.*?)\\] ", "");
			String taskAux = task;
			task = ag + task;
			this.tarefas.set(index, task);
			resposta = "Tarefa atribuída a(o): " + agenteResponsavel.replaceAll("_", " ").toUpperCase(); 
			//Log
			this.log += "[" + dataAtual + " " + hora + "] " + agenteResponsavel.replaceAll("_", " ").toUpperCase() + " - Atribuído à tarefa: " + taskAux + "<br>";
		}
		nomeAgente.set(resposta);
	}
	
	@OPERATION
	void liberaTarefa(String dataAtual, String hora, String agenteResponsavel, OpFeedbackParam<String> tarefa) {
		String resposta = "";
		if (this.tarefas.isEmpty())
			resposta = "Nenhuma tarefa foi cadastrada";
		else {
			int index = -1;
			for (int i = 0; i < responsavelTarefas.size(); i++) {
				List<String> agentes = this.responsavelTarefas.get(i);
				List<Boolean> conclusao = this.conclusaoTarefas.get(i);
				for (int j = 0; j < agentes.size(); j++) {
					if (agentes.get(j).equals(agenteResponsavel)) {
						agentes.remove(j);
						conclusao.remove(j);
						index = i;
						break;
					}
				}
			}
			if (index != -1) {
				List<String> agentes = this.responsavelTarefas.get(index);
				List<Boolean> conclusao = this.conclusaoTarefas.get(index);
				String ag = "[ ";
				for (int i = 0; i < agentes.size(); i++)
					ag += agentes.get(i).replaceAll("_", " ").toUpperCase() + " - ";
				if (ag.contains("-"))
					ag = ag.substring(0, ag.length() - 2);
				ag += "] ";
				String task = this.tarefas.get(index);
				task = task.replaceFirst("\\[(.*?)\\] ", "");
				String taskCompleta = ag + task;
				if (ag.equals("[ ] "))
					this.tarefas.set(index, task);
				else
					this.tarefas.set(index, taskCompleta);
				this.conclusaoTarefas.set(index, conclusao);
				this.responsavelTarefas.set(index, agentes);
				resposta = "Tarefa: " + task + " - LIBERADA";
				// Log
				this.log += "[" + dataAtual + " " + hora + "] " + agenteResponsavel.replaceAll("_", " ").toUpperCase() + " - Liberou a tarefa: " + task + "<br>";
			} else 
				resposta = "Não está responsável por alguma tarefa";
		}
		tarefa.set(resposta);
	}
	
	@OPERATION
	void minhaTarefa(String nome, OpFeedbackParam<String> resultado) {
		String tarefa = "";
		if (this.tarefas.isEmpty())
			tarefa = "Nenhuma tarefa foi cadastrada";
		else {
			if (nome.contains("manager")) {
				for (int i = 0; i < this.tarefas.size(); i++)
					tarefa += this.tarefas.get(i) + "<br>";
			} else {
				int index = -1;
				List<String> agentes = new ArrayList<String>();
				for (int i = 0; i < responsavelTarefas.size(); i++) {
					agentes = this.responsavelTarefas.get(i);
					index = agentes.indexOf(nome);
					if (index != -1) {
						index = i;
						break;
					}
				}
				if (index != -1)
					tarefa = this.tarefas.get(index);
				else
					tarefa = "Não está responsável por alguma tarefa";
			}
		}
		resultado.set(tarefa);
	}
	
	@OPERATION
	void pegarTarefa(String missao, OpFeedbackParam<String> resultado) {
		missao = missao.split("_")[2];
		resultado.set(missao);
	}
	
	@OPERATION
	void tarefaFinalizada(String dataAtual, String hora, String nome, OpFeedbackParam<Integer> posicao, OpFeedbackParam<String> tarefa, OpFeedbackParam<String> resposta) {
		// Tarefa Finalizada
		String answer = "";
		String task = "";
		if (this.tarefas.isEmpty())
			answer = "Nenhuma tarefa foi cadastrada";
		else {
			int index = -1;
			for (int i = 0; i < responsavelTarefas.size(); i++) {
				List<String> agentes = this.responsavelTarefas.get(i);
				List<Boolean> conclusao = this.conclusaoTarefas.get(i);
				for (int j = 0; j < agentes.size(); j++) {
					if (agentes.get(j).equals(nome)) {
						conclusao.set(j, true);
						agentes.set(j, nome + " (Concluído)");
						index = i;
						break;
					}
				}
			}
			if (index != -1) {
				List<String> agentes = this.responsavelTarefas.get(index);
				List<Boolean> conclusao = this.conclusaoTarefas.get(index);
				String ag = "[ ";
				for (int i = 0; i < agentes.size(); i++)
					ag += agentes.get(i).replaceAll("_", " ").toUpperCase() + " - ";
				ag = ag.substring(0, ag.length() - 2);
				ag += "] ";
				task = this.tarefas.get(index);
				task = task.replaceFirst("\\[(.*?)\\] ", "");
				String taskCompleta = ag + task;
				if (ag.equals("[  ] "))
					this.tarefas.set(index, task);
				else
					this.tarefas.set(index, taskCompleta);
				this.conclusaoTarefas.set(index, conclusao);
				posicao.set(index+1);
				// Log
				this.log += "[" + dataAtual + " " + hora + "] " + nome.replaceAll("_", " ").toUpperCase() + " - Finalizou a tarefa: " + task + "<br>";
				// Produtividade
				this.produtividade.add(nome);
			} else
				answer = "Não está responsável por alguma tarefa";
		}
		tarefa.set(task);
		resposta.set(answer);
	}
	
	@OPERATION
	void tarefasPendentes(OpFeedbackParam<String> resultado) {
		String resposta = "";
		String tarefas = "";
		int faltamConcluir = 0;
		if (this.tarefas.isEmpty())
			resposta = "Nenhuma tarefa foi cadastrada";
		else {
			System.out.println(Arrays.asList(this.conclusaoTarefas));
			System.out.println(this.conclusaoTarefas.size());
			for (int i = 0; i < this.tarefas.size(); i++) {
				List<Boolean> conclusao = this.conclusaoTarefas.get(i);
				if (conclusao.isEmpty()) {
					tarefas += this.tarefas.get(i) + "<br>";
					faltamConcluir += 1;
				} else {
					for (int j = 0; j < conclusao.size(); j++) {
						if (!conclusao.get(j)) {
							tarefas += this.tarefas.get(i) + "<br>";
							faltamConcluir += 1;
						}
					}
				}
			}
			if (faltamConcluir == 0)
				resposta = "Sem tarefa(s) pendente(s)";
			else
				resposta = "Falta(m) " + faltamConcluir + " a ser(em) concluída(s):<br>" + tarefas;
		}
		resultado.set(resposta);
	}
	
	@OPERATION
	void concluido(String nome, String dataAtual, String hora, OpFeedbackParam<String> resultado) {
		// Marcar como concluído
		String resposta = "";
		String tarefas = "";
		int faltamConcluir = 0;
		List<String> agentes = new ArrayList<String>();
		List<Boolean> conclusao = new ArrayList<Boolean>();
		for (int i = 0; i < this.conclusaoTarefas.size(); i++) {
			conclusao = this.conclusaoTarefas.get(i);
			agentes = this.responsavelTarefas.get(i);
			for (int j = 0; j < conclusao.size(); j++) {
				if (!conclusao.get(i)) {
					tarefas += "[ " + agentes.get(i) + " ] " + this.tarefas.get(i) + "<br>";
					faltamConcluir += 1;
				}
			}				
		}
		if (faltamConcluir == 0) {
			resposta = "Obrigado por utilizar o sistema!";
			makeDevelopmentCompleted();
			// Log
			this.log += "[" + dataAtual + " " + hora + "] " + nome.replaceAll("_", " ").toUpperCase() + " - Projeto concluído<br>";
		} else
			resposta = "A(s) seguinte(s) tarefa(s) não está(ão) concluída(s):<br>" + tarefas;
		resultado.set(resposta);
	}
	
	@OPERATION
	void precisamAjuda(String nomesAgentes, OpFeedbackParam<String> resultado) {
		String regex = "(\\w+,\\w+)";
		String resposta = "";
		Pattern p = Pattern.compile(regex);
		Matcher m = p.matcher(nomesAgentes);
		while (m.find()) {
			String[] aux = m.group().split(",");
			String[] nome = aux[0].split("_");
			String mensagem = aux[1];
			if (!mensagem.equals("Nenhuma ajuda solicitada"))
				resposta += "[ "+ nome[0].toUpperCase() + " " + nome[1].toUpperCase() + "] " + mensagem + "<br>";
		}		
		if (resposta.equals(""))
			resposta = "Nenhuma ajuda solicitada";
		resultado.set(resposta);
	}
	
	@OPERATION
	void retornaNome(String nomesAgentes, OpFeedbackParam<String> resultado) {
		String regex = "(\\w+,\\w+)";
		String resposta = "";
		Pattern p = Pattern.compile(regex);
		Matcher m = p.matcher(nomesAgentes);
		while (m.find()) {
			String[] aux = m.group().split(",");
			String nome = aux[0];
			String role = aux[1];
			if (this.agentesRemovidos.isEmpty()) {
				if (role.equals("managerRole"))
					resposta += "[LIDER] " + nome.replaceAll("_", " ").replace("manager", "").toUpperCase() + " - ";
				else
					resposta += nome.replaceAll("_", " ").toUpperCase() + " - ";
			} else {
				for (int i = 0; i < this.agentesRemovidos.size(); i++) {
					if (!nome.equals(agentesRemovidos.get(i))) {
						if (role.equals("managerRole"))
							resposta += "[LIDER] " + nome.replaceAll("_", " ").replace("manager", "").toUpperCase() + " - ";
						else
							resposta += nome.replaceAll("_", " ").toUpperCase() + " - ";
					}
				}	
			}
		}
		resultado.set(resposta.substring(0, resposta.length()-3));
	}
	
	@OPERATION
	void retornaNomeExclusao(String nomesAgentes, OpFeedbackParam<String> resultado) {
		String regex = "(\\w+,\\w+)";
		String resposta = "0. Cancelar - ";
		Pattern p = Pattern.compile(regex);
		Matcher m = p.matcher(nomesAgentes);
		int index = 1;
		while (m.find()) {
			String[] aux = m.group().split(",");
			String nome = aux[0];
			String role = aux[1];
			if (this.agentesRemovidos.isEmpty()) {
				if (role.equals("userRole"))
					resposta += index + ". " + nome.replaceAll("_", " ").toUpperCase() + " - ";
				index++;
			} else {
				for (int i = 0; i < this.agentesRemovidos.size(); i++) {
					if (!nome.equals(agentesRemovidos.get(i))) {
						if (role.equals("userRole")) {
							resposta += index + ". " + nome.replaceAll("_", " ").toUpperCase() + " - ";
							index++;
						}
					}
				}
			}
		}
		resultado.set(resposta.substring(0, resposta.length()-3));
	}
	
	@OPERATION
	void removerAgente(String nomesAgentes, String nome, String dataAtual, String hora, int agente, OpFeedbackParam<String> resultado) {
		String resposta = "";
		if (agente == 0)
			resposta = "Operação cancelada";
		else {
			String regex = "(\\w+,\\w+)";
			Pattern p = Pattern.compile(regex);
			Matcher m = p.matcher(nomesAgentes);
			int i = 1;
			while (m.find()) {
				String[] aux = m.group().split(",");
				if (i == agente) {
					resposta = aux[0];
					this.agentesRemovidos.add(aux[0]);
					break;
				}
				i++;
			}
			// Log
			this.log += "[" + dataAtual + " " + hora + "] " + resposta.replaceAll("_", " ").toUpperCase() + " - USUÁRIO REMOVIDO<br>";
		}
		resultado.set(resposta);
	}
	
	@OPERATION
	void descontaAgentes() {
		ObsProperty prop = getObsProperty("qtdAgentes");
		if (prop.intValue() > 0) {
			prop.updateValue(prop.intValue() - 1);
		}
	}

	@OPERATION
	void resetaAgentes() {
		ObsProperty qtdAgentes = getObsProperty("qtdAgentes");
		ObsProperty resetaAgentes = getObsProperty("resetaAgentes");
		qtdAgentes.updateValue(resetaAgentes.intValue());
	}
	
	@OPERATION
	void deliveryDate(String nome, String data, OpFeedbackParam<String> resultado) {	
		String resposta = "";
		if (this.tarefas.isEmpty())
			resposta = "Nenhuma tarefa foi cadastrada";
		else {
			int index = -1;
			List<String> agentes = new ArrayList<String>();
			for (int i = 0; i < responsavelTarefas.size(); i++) {
				agentes = this.responsavelTarefas.get(i);
				for (int j = 0; j < agentes.size(); j++) {
					if (agentes.get(j).equals(nome)) {
						index = j;
						break;
					}
				}
			}
			if (index != -1) {
				List<String> dataLista = Arrays.asList(data.split("/"));
				int parserAno = Integer.parseInt(dataLista.get(2));
				int parserMes = Integer.parseInt(dataLista.get(1));
				int parserDia = Integer.parseInt(dataLista.get(0));
				List<String> dataEntregaLista = Arrays.asList(this.dataTarefas.get(index).split("/"));
				int parserMesEntrega = Integer.parseInt(dataEntregaLista.get(1));
				int parserDiaEntrega = Integer.parseInt(dataEntregaLista.get(0));
				int mes[] = { 31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
				int dias = 0, meses = 0;
				if (dataLista.get(2).charAt(dataLista.get(2).length() - 1) == '0'
						&& dataLista.get(2).charAt(dataLista.get(2).length() - 2) == '0') {
					if (parserAno % 400 == 0) {
						mes[1] = 29;
					} else {
						mes[1] = 28;
					}
				} else if (parserAno % 4 == 0) {
					mes[1] = 29;
				} else {
					mes[1] = 28;
				}
				if (parserMesEntrega > parserMes || parserMes == parserMesEntrega) {
					meses = parserMesEntrega - parserMes;
				} else {
					meses = 12 - (parserMes - parserMesEntrega);
				}
				if (parserDiaEntrega > parserDia || parserDia == parserDiaEntrega) {
					dias = parserDiaEntrega - parserDia;
				} else {
					dias = (mes[parserMes - 1] - parserDia) + parserDiaEntrega;
					meses -= 1;
				}
				resposta = "Falta(m): " + dias + " dia(s) " + meses + " mes(es) para entrega da tarefa";
			} else
				resposta = "Não está responsável por alguma tarefa";
		}
		resultado.set(resposta);
	}
	
	@OPERATION
	void dataTarefa(String nome, OpFeedbackParam<String> resultado) {
		String resposta = "";
		boolean flag = false;
		if (this.tarefas.isEmpty()) {
			resposta = "Nenhuma tarefa foi cadastrada";
			flag = true;
		} else {
			if (nome.contains("manager")) {
				for (int i = 0; i < this.tarefas.size(); i++)
					resposta += "[" + this.dataTarefas.get(i) + "]: " + this.tarefas.get(i) + "<br>";
			} else {
				int index = -1;
				List<String> agentes = new ArrayList<String>();
				for (int i = 0; i < responsavelTarefas.size(); i++) {
					agentes = this.responsavelTarefas.get(i);
					index = agentes.indexOf(nome);
					if (index != -1) {
						index = i;
						break;
					}
				}
				if (index != -1)
					resposta = "[" + this.dataTarefas.get(index) + "]: " + this.tarefas.get(index) + "<br>";
				else {
					resposta = "Não está responsável por alguma tarefa";
					flag = true;
				}
			}
		}
		if (flag)
			resultado.set(resposta);
		else
			resultado.set("Data(s) de entrega(s):<br>" + resposta);
	}

	@OPERATION
	void makeDevelopmentCompleted() {
		ObsProperty makeDevelopment = getObsProperty("fazer_desenvolvimento");
		makeDevelopment.updateValue(true);
	}
}
