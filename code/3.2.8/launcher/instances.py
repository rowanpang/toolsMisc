import os
import sys

current_path = os.path.dirname(os.path.abspath(__file__))
root_path = os.path.abspath( os.path.join(current_path, os.pardir))
data_path = os.path.abspath(os.path.join(root_path, os.pardir, os.pardir, 'data'))
data_launcher_path = os.path.join(data_path, 'launcher')
python_path = os.path.join(root_path, 'python27', '1.0')
noarch_lib = os.path.abspath( os.path.join(python_path, 'lib', 'noarch'))
sys.path.append(noarch_lib)

from xlog import Logger
log_file = os.path.join(data_launcher_path, "launcher.log")
xlog = Logger(file_name=log_file)
