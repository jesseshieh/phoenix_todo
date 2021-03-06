defmodule SimpleTodoWeb.TodoController do
  use SimpleTodoWeb, :controller
  alias SimpleTodo.Repo
  import Ecto.Query

  def index conn, _params do
    todos = Repo.all(from t in Todo, order_by: t.id)
    changeset = Todo.changeset %Todo{}

    render conn, :index, todos: todos, changeset: changeset
  end

  def show conn, %{"id" => todo_id} do
    todo = Repo.get Todo, todo_id
    render conn, :show, todo: todo
  end

  def edit conn, %{"id" => todo_id} do
    todo = Repo.get Todo, todo_id
    changeset =  Todo.changeset todo
    render conn, :edit, changeset: changeset, todo: todo
  end

  def create conn, %{"todo" => todo} do
    todos = Repo.all(from t in Todo, order_by: t.id)

    %Todo{}
    |> Todo.changeset(todo)
    |> Repo.insert()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Todo Created")
        |> redirect(to: todo_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render(:index, todos: todos, changeset: changeset)
    end
  end

  def update conn, %{"todo" => todo_data, "id" => todo_id} do
    todo = Repo.get(Todo, todo_id)

    todo
    |> Todo.changeset(todo_data)
    |> Repo.update
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: todo_path(conn, :show, todo))
      {:error, changeset} ->
        conn
        |> render(:edit, changeset: changeset, todo: todo)
    end
  end

  def delete conn, %{"id" => todo_id} do
    Repo.get(Todo, todo_id) |> Repo.delete

    conn
    |> put_flash(:info, "Todo Deleted")
    |> redirect(to: todo_path(conn, :index))
  end

  def toggle_completed conn, %{"id" => todo_id} do
    todo = Repo.get(Todo, todo_id)

    {:ok, todo} = todo
    |> Todo.changeset(%{completed: !todo.completed})
    |> Repo.update

    conn |> redirect(to: todo_path(conn, :show, todo))
  end
end
