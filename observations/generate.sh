# Profiling:
# $ `time bash ./generate.sh 1000 > /dev/nul`
# real    0m4.651s - 0m4.994s

num_rows=$1

names=(
    '"name": {"coding": [{"system": "http://loinc.org", "code": "8310-5", "display": "Body temperature"}], "text": "Body temperature"},'
    '"name": {"coding": [{"system": "http://loinc.org", "code": "55284-4", "display": "Blood pressure systolic \& diastolic"}]},'
)
applies=(
    '"appliesDateTime": "{{rand_date}}T09:30:10+01:00",'
    '"appliesPeriod": {"start": "{{rand_date}}T09:30:10+01:00", "end": "{{rand_date2}}T09:30:10+01:00"},'
)
statuses=(
    "amended"
    "cancelled"
    "entered in error"
    "final"
    "preliminary"
    "registered"
)

for ((i = 1; i <= $num_rows; i++)); do
    patient_id=$(($i%1000))
    status=${statuses[$((RANDOM%6))]}

    name_index=$((RANDOM%3))
    if (($name_index < 2)); then
        name=${names[$name_index]}
    else
        name="\"name\": {\"coding\": [{\"system\": \"http://loinc.org\", \"code\": \"noise-$name_index\", \"display\": \"noise $name_index\"}], \"text\": \"Noise $name_index\"},"
    fi

    apply_index=$((RANDOM%3))
    if (($apply_index < 2)); then
        rand_y=$((RANDOM%2+2013))
        rand_m=$((RANDOM%11+1))
        rand_d=$((RANDOM%15+1))
        rand_d2=$(($rand_d+3))
        rand_date=`date -d "$rand_y-$rand_m-$rand_d" '+%Y-%m-%d'`
        rand_date2=`date -d "$rand_y-$rand_m-$rand_d2" '+%Y-%m-%d'`
        apply=$(
            echo ${applies[$apply_index]} \
                | sed -e "s/{{rand_date}}/$rand_date/" \
                      -e "s/{{rand_date2}}/$rand_date2/"
        )
    else
        apply=""
    fi

    sed -e "s/{{patient_id}}/$patient_id/g"  \
        -e "s@{{name}}@$name@" \
        -e "s@{{applies}}@$apply@" \
        -e "s/{{status}}/$status/g" \
        -e ':a;N;$!ba;s/\n/ /g' \
        template.json
done
