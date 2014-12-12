# NOT ANOTHER SOURCE THIS!!!!!
#
# But, you know... do it. Source this file!
# It sets up virtualenv and stuff.
# It also defines the function test-gamboge() which does what you think it
# does.

if [ ! -d ./evaluation_utils/.venv ] ; then
    virutalenv ./evaluation_utils/.venv
    pip install -r ./evaluation_utils/requirements.txt
fi

source ./evaluation_utils/.venv/bin/activate

function test-gamboge() {
    python ./evaluation_utils/upload.py $@
}
