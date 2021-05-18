// CArtAgO artifact code for project smartjason_integrado

package board;

import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.logging.Logger;

import cartago.*;
import jason.asSyntax.Literal;
import service.FirebaseInitialize;
import service.FirebaseService;
import objects.Task;
import objects.User;

public class Group extends Artifact {

	Literal start;

	String manager = null;

	List<String> listaManagers = new ArrayList<String>();
	List<String> listaAgentes = new ArrayList<String>();

	String projeto = null;
	String descricao = null;
	
	// Log
	String intentLog = null;
	
	HashMap<String, Integer> log = new HashMap<String, Integer>();

	void init() {
		FirebaseInitialize fb = new FirebaseInitialize();
		fb.initialize();
	}

	// Log dos grupos
	
	@OPERATION
	void updateLog(String log, String nome) {
		try {
			// Log
			String localLog = nome + "_log.txt";
			FileWriter fw = new FileWriter(localLog, true);
			String resposta = "[" + nome + "]: " + log.replace("<br>", System.lineSeparator());
			fw.write(resposta);
			fw.write(System.lineSeparator());
			fw.write(System.lineSeparator());
			fw.close();
			// System Log
			String systemLog = "systemLog.txt";
			FileWriter fwSystem = new FileWriter(systemLog);
			fwSystem.write(this.intentLog);
			fwSystem.close();
		} catch (IOException ioe) {
			System.err.println("IOException: " + ioe.getMessage());
		}
	}
	
	// Log do sistema

	@OPERATION
	void systemLog(String intent, String nome) {
		DateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
		Date date = new Date();
		this.intentLog += "[" + dateFormat.format(date) + "]" + " Recebido (" + nome + ") intent:  "  + intent + "\n";
		if (this.log.containsKey(intent)) {
			int qtd = this.log.get(intent);
			qtd += 1;
			this.log.replace(intent, qtd);
		} else
			this.log.put(intent, 1);	
	}
	
	// Estatística do log do sistema
	
	@OPERATION
	void systemStatistic() {
		try {
			String filename = "statistic.txt";
			FileWriter fw = new FileWriter(filename, false);
			for (String intent : this.log.keySet()) {
				fw.write("Intent: " + intent + " (" + this.log.get(intent) + ")\n");
			}
			fw.close();
		} catch (IOException ioe) {
			System.err.println("IOException: " + ioe.getMessage());
		}
	}

	@OPERATION
	void inicializa(String requisicaoNome) {
		this.listaManagers.clear();
		this.listaAgentes.clear();
		new FirebaseService().getUserList(requisicaoNome, new FirebaseService.DataStatus() {
			@Override
			public void DataIsLoaded(List<User> grupos, List<String> keys) {
				String nome = "";
				for (int i = 0; i < grupos.size(); i++) {
					if (grupos.get(i).getRole().toLowerCase().equals("manager")) {
						nome = grupos.get(i).getNome().replaceAll(" ", "_");
						nome = nome.toLowerCase() + "_manager";
						listaManagers.add(nome.trim());
						if (requisicaoNome.equals(nome))
							manager = nome.trim();
					} else if (grupos.get(i).getRole().equals("user")) {
						nome = grupos.get(i).getNome().replaceAll(" ", "_").toLowerCase();
						listaAgentes.add(nome.trim());
					}
				}
			}
		}, new FirebaseService.DataStatusTask() {
			@Override
			public void DataIsLoaded(List<Task> tarefas, List<String> keys) {
				for (int i = 0; i < tarefas.size(); i++) {
					descricao = tarefas.get(i).getDescricao();
					projeto = tarefas.get(i).getProjeto();
				}
				execInternalOp("loadProperties");
			}
		});
	}

	@INTERNAL_OPERATION
	void loadProperties() {
		start = Literal.parseLiteral("start(" + manager + "," + listaAgentes + ")");
		defineObsProperty("grupo", start);
		defineObsProperty("projeto", projeto);
		defineObsProperty("descricao", descricao);
	}

	@OPERATION
	void mostraGrupos(OpFeedbackParam<String> resultado) {
		String resposta = "Selecione um grupo<br>";
		for (int i = 0; i < this.listaManagers.size(); i++) {
			String[] nome = this.listaManagers.get(i).split("_");
			resposta += (i + 1) + ". " + nome[0].toUpperCase() + " " + nome[nome.length - 1].toUpperCase() + "<br>";
		}
		resultado.set(resposta);
	}

	@OPERATION
	void pegarGrupo(int index, OpFeedbackParam<String> resultado) {
		resultado.set(this.listaManagers.get(index - 1));
	}
}
