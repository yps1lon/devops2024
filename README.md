  OPG 1A
    https://15vvf1l045.execute-api.eu-west-1.amazonaws.com/Prod/generate-image

  1B
    https://github.com/yps1lon/devops2024/actions/runs/11845619412/job/33011480515
	
OPG2A
https://eu-west-1.console.aws.amazon.com/sqs/v3/home?region=eu-west-1#/queues/https%3A%2F%2Fsqs.eu-west-1.amazonaws.com%2F244530008913%2Fimage-gen-4/send-receive
 
 
 	2B
https://github.com/yps1lon/devops2024/actions/runs/12018518541/job/33503163705
https://github.com/yps1lon/devops2024/actions/runs/11937161109/job/33272482541

OPG3
fikk ikke til

OPG4
Se TF kode, terraform.tfvars og sqs.tf

OPG 5
CI/CD og automatisering
Mikrotjenester trenger ofte at alle servicene og funksjonene er bygd individuelt fra hverandre. Dette fører til et større arbeidslass fordi da må en teste og deploye dette også evt til en Docker eller en annen type platform som feks Kubernetes. Det er positivt på den måten at utviklerne selv får mer kontroll over hva som foregår, men gir ulempen over at det blir mer arbeid å gjøre i form av maintnence, kordinasjon og ikke minst tid. Serverless derimot er bygd for rask utvikling, noe som gjør at en del arbeidsoppgaver faller bort bare på grunn av bedre automatisering.

Observability 
Det blir enklere å få innsikt i systemer som er mikrotjeneste baserte på grunn av containers eller VMs, mens dette blir litt mer vanskelig i serverløse systemer hvor tjenestene trigges uavhengig av hverandre. AWS har CloudWatch som kan være til hjelp når man vil vite hva som skaper problemer ved det faktumet at det er klart og analyserbart igjennom en graf, men som nevnt tidligere så gir mikrotjenester utviklerne selv MER kontroll. noe som lar de ta en dypdykk inn i programmet uten å måtte bruke mange eksterne verktøy.

Skalerbarhet og kostnader
Serverløse systemer skalerer automatisk etter behov, noe som gjør dem svært kostnadseffektive, siden man kun betaler for ressursene som faktisk brukes. Dette gjør dem spesielt nyttige for arbeidsmengder med uforutsigbar trafikk, men problemer som cold starts kan oppstå, noe som kan påvirke brukervennlighet. Mikrotjenester gir derimot bedre forutsigbarhet og kontroll, men har faste kostnader. som betyr at et utvikler team betaler for alle tjenester, selvom noen blir brukt mindre enn andre. dette kan føre til høyere kostnader når systemet ikke brukes fult.

Eierskap og ansvar
En serverløs løsning reduserer ansvaret for infrastruktur, siden skyen håndterer dette (feks AWS). Teamene kan derfor fokusere mer på  funksjonalitet og optimalisering. I en mikrotjenestebasert løsning, der team har ansvar for både infrastruktur og applikasjon, kreves mer omfattende arbeid for å sikre stabilitet og ytelse. En mikrotjeneste basert løsning kan gi teamet mer eierskap og løsning enn en serverless løsning.

Konklusjon
Serverløse løsninger passer best for dynamiske oppgaver og situasjoner hvor smidighet er viktig, mens mikrotjenester gir bedre kontroll og stabilitet. Valget mellom disse avhenger av arbeidsmengder, teamets kompetanse og behov. Airbnb for eksempel bruker Lambda funksjoner og serverless til sin booking del av nettsiden, dette hjelper de med skalerbarhet når det er mye pågang feks om sommeren, når det er flere som er ute og reiser. Mens Netflix feks er en mikrotjeneste basert løsning som funker fint som den er, men kan støte på problemer når det gjelder pågang. Feks under streamingen mellom Jake Paul vs Mike Tyson for noen uker siden.

Kilder:

https://talent500.com/blog/microservices-vs-serverless/#DecisionMaking_Criteria
https://www.ibm.com/blog/serverless-vs-microservices/
https://aws.amazon.com/blogs/compute/comparing-design-approaches-for-building-serverless-microservices/
https://amplication.com/blog/serverless-vs-containers-for-microservices-what-should-you-choose
https://www.devprojournal.com/software-development-trends/pros-and-cons-of-function-as-a-service-faas/
