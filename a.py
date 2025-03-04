import importlib.util
import sys
from pathlib import Path

# Calculate the parent directory path
parent_dir = Path(_file_).resolve().parent.parent

# Add the parent directory to sys.path
sys.path.insert(0, str(parent_dir))

# Import the remove-bakery module
remove_bakery_spec = importlib.util.spec_from_file_location('remove_bakery', parent_dir / 'remove-bakery.py')
remove_bakery = importlib.util.module_from_spec(remove_bakery_spec)
remove_bakery_spec.loader.exec_module(remove_bakery)

# Import the helpers module
# helpers_spec = importlib.util.spec_from_file_location('helpers', parent_dir / 'tests' / 'helpers.py')
# helpers = importlib.util.module_from_spec(helpers_spec)
# helpers_spec.loader.exec_module(helpers)

# Now you can use the functions from the imported modules
print(remove_bakery.remove_bakery_function()) # Output: Function from remove-bakery
# print(helpers.helper_function())              # Output: Helper function