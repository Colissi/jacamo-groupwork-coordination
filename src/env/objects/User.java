package objects;


public class User {
	private String key;
	private String nome;
	private String projeto;
	private String role;
	private String raiz;
	
	public User() {
		
	}
	
	public User(String nome, String projeto, String role, String raiz, String key) {
		this.nome = nome;
		this.projeto = projeto;
		this.role = role;
		this.raiz = raiz;
		this.key = key;
	}
	
	public String getNome() {
		return nome;
	}
	
	public void setNome(String nome) {
		this.nome = nome;
	}
	
	public String getProjeto() {
		return projeto;
	}
	
	public void setProjeto(String projeto) {
		this.projeto = projeto;
	}
	
	public String getRole() {
		return role;
	}
	
	public void setRole(String role) {
		this.role = role;
	}
	
	public void setRaiz(String raiz) {
		this.raiz = raiz;
	}
	
	public String getRaiz() {
		return raiz;
	}
	
	public String getKey() {
		return key;
	}
	
	public void setKey(String key) {
		this.key = key;
	}
}
