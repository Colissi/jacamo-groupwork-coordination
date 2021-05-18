package objects;

public class Task {
	
	private String descricao;
	private String projeto;
	private String raiz;
	
	public Task() {
		
	}
	
	public Task(String descricao, String projeto) {
		this.descricao = descricao;
		this.projeto = projeto;
	}
	
	public String getDescricao() {
		return descricao;
	}
	
	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}
	
	public String getProjeto() {
		return projeto;
	}
	
	public void setProjeto(String projeto) {
		this.projeto = projeto;
	}
	
	public String getRaiz() {
		return raiz;
	}
	
	public void setRaiz(String raiz) {
		this.raiz = raiz;
	}
}
