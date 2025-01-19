# 🗃️ Experimental
Este repositório foi criado com o intuito de armazenar código para estudo, qualquer tentativa de replicar seu conteúdo demandará adaptações consideráveis.

# 🔨 O que este código faz?
Este código dispõe de um servidor dedicado com back-end escrito em Lua utilizando [Nakama Godot](https://heroiclabs.com/nakama/), sua arquitetura é autoritativa, o servidor criará uma sala assim que iniciado, ela permanecerá aberta a todos os jogadores que posteriormente se conectarem, atualizando suas posições x e y bem como seu apelido dez vezes por segundo, taxa essa que pode ser alterada nos módulos do servidor.

![Ya1JT](https://github.com/user-attachments/assets/e3079ae7-2adf-46e3-bdfb-ea59bb6bed30)

# 🎯 Qual o objetivo?
Demonstrar a responsibilidade de um servidor autoritativo e sua demanda por recursos computacionais em casos aplicados a linha de produção.

# 📜 Considerações finais
- Conhecimento em Lua, Go ou Typescript é indispensável
- A documentação para utilização da API fornecida pelo back-end Nakama, em GDscript 2.0, é desatualizada e insatisfatória.
- Desempenho geral aceitável
