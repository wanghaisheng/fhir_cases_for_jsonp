Cases for jsonp by Medclient HS-Choice


1. My Encounters for emergency:

FHIR encounter resource is described - http://www.hl7.org/implement/standards/fhir/encounter.html


Select active emergency encounters where 'doc1' is attending or admiting physician:

```
  Encounter.class = 'emergency'
  Encounter.status not in ('planned', 'finished', 'cancelled')

  Encounter
    .participant*
      [.individual
        .type*.coding* [ .coding.code in ('ADM', 'ATND')
                         AND
                         .coding.system = 'encounter-participant-type' ]
       AND .individual.reference = 'concrete physician' ]
```

query as json with functions

```json
{
  "class": "emergency",
  "status": $not($in("planned","finished","cancelled")),
  "participant": $some({
     "individual": $some({
       "reference" : "Doc1"
       "type": $some({
          "coding": $some({
             "code": $in("ADM","ATND"),
             "system": "encounter-participant-type"
          })
       })
     })
   })
}

```

magic key variation


```
{
  "participant": {
     $some : {
       "individual" : {
          $some: {
            "reference": "Doc1",
            "coding": {
              $some: {
               "code": $in("ADM","ATND"),
               "system": "encounter-participant-type"
              }
            }
          }
       }
     }
   }
}
```

or in python (coffeescript) style

```
class: "emergency",
status:
  $not:
    $in: ["planned","finished","cancelled"]
participant:
  $some:
    individual:
      $some:
        reference: "Doc1"
        coding:
          $some:
            code:
              $in: ["ADM","ATND"]
            system: "encounter-participant-type"
```

clojure/edn style

```
{:class "emergency"
 :status (not(in ["planned", ...]))
 :participant #some {
   :individual #some {
     :reference "Doc1"
     :coding #some {
        :code #in ["ADM","ATND"]
        :system "encounter-participant-type" }}}}
```

To generate test data:

```bash

  git clone https://github.com/niquola/fhir_cases_for_jsonp.git

  cd fhir_cases_for_jsonp

  env FHIR_NUM=1000 FHIR_HOME=`pwd` psql -d <db> < generate_encounters.sql
```


Generation script in generate_encouters.sh
