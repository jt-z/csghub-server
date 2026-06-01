import os

c.ServerApp.ip = '0.0.0.0'
c.ServerApp.token = ""
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.port_retries = 0
c.ServerApp.quit_button = False
c.ServerApp.allow_remote_access = True
c.ServerApp.disable_check_xsrf = True
c.ServerApp.allow_origin = '*'
c.ServerApp.trust_xheaders = True
c.ServerApp.open_browser = False
c.ServerApp.answer_yes = True
c.ServerApp.tornado_settings = {
    "headers": {
        "Content-Security-Policy": "frame-ancestors 'self' *"
    }
}

c.ServerApp.checkpoints_class = "jupyter_server.services.contents.checkpoints.AsyncCheckpoints"

c.FileContentsManager.delete_to_trash = False

c.ContentsManager.allow_hidden = True

c.Completer.use_jedi = False

c.NotebookApp.iopub_msg_rate_limit = 100000000
c.NotebookApp.iopub_data_rate_limit = 2147483647

c.FileContentsManager.always_delete_dir = True