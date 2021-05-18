package service;

import objects.Task;
import objects.User;

import java.util.ArrayList;
import java.util.List;

import org.jvnet.hk2.annotations.Service;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

@Service
public class FirebaseService {
	
	private List<User> grupos = new ArrayList<User>();
	private List<Task> tarefas = new ArrayList<Task>();
	private FirebaseDatabase database;
	private DatabaseReference databaseRef;
	private DatabaseReference databaseRefTask;
	
	public interface DataStatus {
		void DataIsLoaded(List<User> grupos, List<String> keys);
	}
	
	public interface DataStatusTask {
		void DataIsLoaded(List<Task> tarefa, List<String> keys);
	}
	
	public FirebaseService() {		
		database = FirebaseDatabase.getInstance();
		databaseRef = database.getReference("usuarios");
		databaseRefTask = database.getReference("tarefas");
	}
	
	public void getUserList(String nome, final DataStatus dataStatus, final DataStatusTask dataStatusTask) {
		databaseRef.orderByChild("raiz").equalTo(nome).addValueEventListener(new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot snapshot) {
				grupos.clear();
				List<String> keys = new ArrayList<String>();
				for (DataSnapshot keyNode : snapshot.getChildren()) {
					keys.add(keyNode.getKey());
					User grupo = keyNode.getValue(User.class);
					grupos.add(grupo);
				}
				dataStatus.DataIsLoaded(grupos, keys);
			}
			
			@Override
			public void onCancelled(DatabaseError error) {
				System.out.println("The read failed: " + error.getCode());
			}
		});
		
		databaseRefTask.orderByChild("raiz").equalTo(nome).addValueEventListener(new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot snapshot) {
				tarefas.clear();
				List<String> keys = new ArrayList<String>();
				for (DataSnapshot keyNode : snapshot.getChildren()) {
					keys.add(keyNode.getKey());
					Task tarefa = keyNode.getValue(Task.class);
					tarefas.add(tarefa);
				}
				dataStatusTask.DataIsLoaded(tarefas, keys);
			}
			
			@Override
			public void onCancelled(DatabaseError error) {
				System.out.println("The read failed: " + error.getCode());
			}
		});
	}
}
