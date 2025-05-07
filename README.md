# SICE - Sistema de Inventário e Controle de Estoque

Aplicativo mobile para gerenciamento de inventário e controle de estoque através de leitura de QR codes.

## Sobre o Projeto

O SICE (Sistema de Inventário e Controle de Estoque) é um aplicativo Flutter desenvolvido para simplificar a gestão de inventários e movimentação de itens. Utilizando a tecnologia de escaneamento de QR codes, o aplicativo oferece uma maneira rápida e precisa de identificar, rastrear e gerenciar itens em estoque.

## Principais Funcionalidades

- **Movimentação de Itens**: Escaneamento de QR codes para rápida identificação e movimentação de itens entre locais
- **Consulta de Itens/Locais**: Verificação rápida de informações sobre itens e locais de armazenamento
- **Cadastro de Itens/Locais**: Interface para adicionar novos itens e locais no sistema

## Tecnologias Utilizadas

- Flutter para desenvolvimento cross-platform (Android e iOS)
- Câmera integrada para leitura de QR codes
- Gerenciamento de permissões para acesso à câmera

## Requisitos

- Flutter 2.x ou superior
- Dart 2.12.0 ou superior
- Dispositivo com câmera ou emulador compatível

## Instalação

1. Clone este repositório
   ```
   git clone https://github.com/seu-usuario/sice_app.git
   ```

2. Navegue até o diretório do projeto
   ```
   cd sice_app
   ```

3. Instale as dependências
   ```
   flutter pub get
   ```

4. Execute o aplicativo
   ```
   flutter run
   ```

## Permissões Necessárias

O aplicativo requer as seguintes permissões:

- **Câmera**: Para leitura de QR Code