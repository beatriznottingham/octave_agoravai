clear; clc; home;
pkg load instrument-control; % Carrega o pacote 'instrument-control' para comunicação com dispositivos

% Cria um cliente TCP
tcpClient = tcpclient("10.10.1.1", 12344);  % IP e porta do servidor de destino

disp("Lendo a mensagem do arquivo msg.txt...");

% Lê o conteúdo do arquivo 'msg.txt' como uma string
fid = fopen('msg.txt', 'r');  % Abre o arquivo para leitura
if fid == -1
    error("Erro ao abrir o arquivo msg.txt");
end
largeData = fscanf(fid, '%c');  % Lê todo o conteúdo do arquivo como uma string
fclose(fid);  % Fecha o arquivo

disp("Enviando mensagem para o servidor...");  % Mensagem de status

% Define o tamanho máximo de cada pacote TCP para 65.535 bytes
chunkSize = 65535;  % Tamanho máximo do pacote TCP (em bytes)

% Calcula o número de pacotes necessários para enviar os dados
numChunks = ceil(length(largeData) / chunkSize);

pause(0.1);  % Pausa breve para evitar sobrecarga da CPU

% Loop para enviar os dados em pacotes fragmentados
for i = 1:numChunks
    % Calcula os índices de início e fim do pacote
    startIdx = (i - 1) * chunkSize + 1;  % Índice de início do pacote
    endIdx = min(i * chunkSize, length(largeData));  % Índice de fim do pacote (garante que não ultrapasse o final dos dados)

    % Extrai o bloco de dados correspondente ao pacote
    chunk = largeData(startIdx:endIdx);

    % Cria uma mensagem com a ordem dos pacotes (número atual e total)
    message = sprintf("%d/%d|%s", i, numChunks, chunk);

    % Envia o pacote TCP com a mensagem para o servidor
    write(tcpClient, message);  % Envia a mensagem via TCP

    pause(0.2);  % Pausa breve para evitar sobrecarga da rede
end

disp("Mensagem enviada com sucesso!");
