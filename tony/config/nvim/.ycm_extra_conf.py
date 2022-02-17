from sys import executable

def Settings(**kwargs):
    return {
        'interpreter_path': executable
    }
