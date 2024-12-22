clear; clc; home;

% Carrega o pacote instrument-control para comunicação TCP
pkg load instrument-control;

% Configurações de conexão
SERVER_IP = "localhost";
SERVER_PORT = 12345;
CHUNK_SIZE = 65535;  % Tamanho máximo do pacote TCP (bytes)
FILE_PATH = 'bootstat.dat';

% Configuração do cliente TCP
try
    tcpClient = tcpclient(SERVER_IP, SERVER_PORT);
catch err
    error('Erro ao criar cliente TCP: %s', err.message);
end

% Abre e verifica o arquivo
try
    fid = fopen(FILE_PATH, 'rb');
    if fid == -1
        error('Não foi possível abrir o arquivo: %s', FILE_PATH);
    end

    % Obtém tamanho do arquivo
    fileInfo = stat(FILE_PATH);
    fileSize = fileInfo.size;
    numChunks = ceil(fileSize / CHUNK_SIZE);

    % Inicializa contadores
    bytesRead = 0;
    bytesTotal = fileSize;

    % Loop principal de transmissão
    disp('Iniciando transmissão do arquivo...');
    tic;  % Inicia cronômetro

    while bytesRead < bytesTotal
        for i = 1:numChunks
            % Calcula tamanho do próximo chunk
            remainingBytes = bytesTotal - bytesRead;
            currentChunkSize = min(CHUNK_SIZE, remainingBytes);

            % Lê chunk do arquivo
            chunk = fread(fid, currentChunkSize, '*uint8');
            if isempty(chunk)
                break;
            end

            % Cria header para este chunk
            header = uint8(sprintf("%d/%d|", i, numChunks))';

            % Monta e envia pacote
            packet = [header; chunk];
            bytesWritten = write(tcpClient, packet);

            bytesRead = bytesRead + length(chunk);

            % Mostra progresso
            progress = (bytesRead / bytesTotal) * 100;
            fprintf('\rProgresso: %.1f%% (%d/%d bytes)', progress, bytesRead, bytesTotal);

            % Pequena pausa para controle de fluxo
            pause(0.01);
        end
    end

    % Finalização e estatísticas
    transmissionTime = toc;
    transferRate = (bytesTotal / (1024 * 1024)) / transmissionTime;  % MB/s

    fprintf('\n\nTransferência concluída:\n');
    fprintf('Tempo total: %.2f segundos\n', transmissionTime);
    fprintf('Taxa de transferência média: %.2f MB/s\n', transferRate);
    fprintf('Total de bytes transferidos: %d\n', bytesRead);

catch err
    fprintf('\nErro durante a transferência: %s\n', err.message);
end

% Limpeza
if exist('fid', 'var') && fid ~= -1
    fclose(fid);
end
if exist('tcpClient', 'var')
    clear tcpClient;
end