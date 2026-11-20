# Capítulo 01 — Estação de Vespera

## Objetivo da vertical slice
Entregar uma cena de aventura point-and-click em orientação horizontal para Android/iOS, com inventário, exploração e um puzzle funcional.

## Fluxo
1. Elara chega à plataforma vazia.
2. Examina o relógio parado às 00h13.
3. Investiga o banco e a bagagem.
4. Encontra engrenagens e repara o relógio.
5. Descobre a pista necessária para abrir um mecanismo na bilheteria.

## Direção visual aprovada
Fantasia histórica vitoriana, neblina azul-acinzentada, iluminação âmbar, arquitetura detalhada e efeitos ambientais sutis. Os elementos interativos precisam ser legíveis em telas de celular.

## Plano técnico
- Godot 4, renderizador Compatibility.
- Cenas separadas para plataforma, sala de espera e bilheteria.
- Hotspots com estados persistentes.
- Inventário com ações examinar, combinar e usar.
- Salvamento local.
- Recursos de arte próprios em camadas (fundo, arquitetura, primeiro plano, objetos e partículas).

## Critérios de aceite
- O projeto abre sem erros no Godot 4.
- A cena inicial aparece corretamente em 16:9 e proporções mobile mais largas.
- Todos os hotspots respondem a toque e mouse.
- O jogador consegue coletar itens e reparar o relógio.
- O estado da cena persiste após salvar e reabrir.
- Nenhum puzzle exige adivinhação sem pista.

## Situação
O protótipo v0.2 existe em pacote ZIP local. Sua importação integral para este repositório e sua validação no editor ainda estão pendentes.
