pkg load instrument-control;  % Carregar o pacote instrument-control

% Configurações iniciais:
SERVER_IP = "localhost";
SERVER_PORT = 12345;


% Criar o servidor TCP:
server = tcpserver(SERVER_PORT);

disp("Servidor aguardando conexão...");

% Esperar até que um cliente se conecte
while ~server.Connected
  pause(0.1);  % Pequena pausa para evitar sobrecarregar a CPU
end

disp("Cliente conectado!");

% Ler dados enviados pelo cliente
while server.Connected
  data = readline(server);  % Lê a linha de dados enviada pelo transmissor
  if !isempty(data)  % Verifica se há dados recebidos
    disp(["Mensagem recebida: ", data]);  % Exibe a mensagem recebida
  end
end

% Fechar a conexão
clear server;
disp("Conexão encerrada.");