# Vespera — vertical slice 0.2

## Identidade visual
Fantasia histórica vitoriana, pedra azul-acinzentada, metais de latão, luz quente, neblina fria, relógios e memória.

## Primeira cena
Plataforma: relógio e banco são hotspots clicáveis; sala de espera: tábua e cartaz; bilheteria: armário e balcão. Os botões laterais permanecem como alternativa de acessibilidade.

## Pipeline definitivo de arte
1. Pintar cenário mestre em 2560x1440.
2. Exportar fundo, arquitetura, primeiro plano, objetos e máscaras de hotspots separadamente em PNG/WebP.
3. Animar neblina, partículas e luz na Godot com parallax e shaders leves.
4. Substituir a ilustração vetorial temporária em `station_view.gd` sem mudar a lógica de inventário em `main.gd`.
5. Testar legibilidade e alvos de toque em dispositivos físicos.

## Critérios de aceite
- Navegar entre 3 locais.
- Obter duas engrenagens e reparar o relógio.
- Obter passagem com símbolos.
- Resolver combinação estrela-lua-sol.
- Receber lente e documento; salvar e retomar.

## Limitações
Arte vetorial provisória, sem áudio ou APK; não testado no editor Godot nesta entrega.
