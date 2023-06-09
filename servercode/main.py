import os
import glob
from flask import Flask, request, render_template, abort
import jsmin

app = Flask(__name__)

@app.route('/demo/<string_parameter>')
def homepage(string_parameter):

    info = {
      "project_name": string_parameter,
      "project_features": [
        {
            "id": "VoiceOver",
            # "task": "ok",
            "status": "Complete"
        },
        {
            "id": "Adjustable text sizes",
            # "task": "ok",
            "status": "Complete"
        },
        {
            "id": "Differentiate without colors",
            # "task": "ok",
            "status": "In Progress"
        },
        {
            "id": "Color filters",
            # "task": "ok",
            "status": "In Progress"
        }
      ]
    }
    return render_template("demo.html", info = info)

@app.route('/get_main_app_script', methods=['POST'])
def get_main_app_script():
  # Extract the input string from the JSON request data
  project_id = request.json.get('project_id', '')

  file_content = ""
  if not os.path.exists('JSProjects/shared.js'):
    abort(404, "Can't find main file")
  with open('JSProjects/shared.js', 'r') as sharedJSFile:
    file_content = file_content + sharedJSFile.read()

  if not os.path.exists(f'JSProjects/{project_id}'):
    abort(404, f"Can't find project directory for {project_id}")

  js_files = glob.glob(os.path.join(f'JSProjects/{project_id}', '*.js'))

  for file in js_files:
    with open(file, 'r') as f:
      file_content = file_content + f.read()

  return jsmin.jsmin(file_content)

def update_task_entry(task_id: int, text: str) -> None:
    """Updates task description based on given `task_id`

    Args:
        task_id (int): Targeted task_id
        text (str): Updated description

    Returns:
        None
    """

    # conn = db.connect()
    # query = 'Update tasks set task = "{}" where id = {};'.format(text, task_id)
    # conn.execute(query)
    # conn.close()


def update_status_entry(task_id: int, text: str) -> None:
    """Updates task status based on given `task_id`

    Args:
        task_id (int): Targeted task_id
        text (str): Updated status

    Returns:
        None
    """

    # conn = db.connect()
    # query = 'Update tasks set status = "{}" where id = {};'.format(text, task_id)
    # conn.execute(query)
    # conn.close()


def insert_new_task(text: str) ->  int:
    """Insert new task to todo table.

    Args:
        text (str): Task description

    Returns: The task ID for the inserted entry
    """

    # conn = db.connect()
    # query = 'Insert Into tasks (task, status) VALUES ("{}", "{}");'.format(
    #     text, "Todo")
    # conn.execute(query)
    # query_results = conn.execute("Select LAST_INSERT_ID();")
    # query_results = [x for x in query_results]
    # task_id = query_results[0][0]
    # conn.close()

    return 1


def remove_task_by_id(task_id: int) -> None:
    """ remove entries based on task ID """
    # conn = db.connect()
    # query = 'Delete From tasks where id={};'.format(task_id)
    # conn.execute(query)
    # conn.close()



app.run(host='0.0.0.0', port=8080)
