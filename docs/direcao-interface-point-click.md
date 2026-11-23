# Direção de produção — interface point-and-click

## Princípios inegociáveis
- Preservar o roteiro aprovado de O Arquivo das Horas Perdidas, Elara Voss, Estação de Vespera e paradoxo temporal.
- Preservar a identidade visual de fantasia sombria, azul profundo, dourado envelhecido, sépia, arquitetura vitoriana e atmosfera cinematográfica.
- Referências de mecânicas: Lost Lands e Legendary Tales, sem copiar seus recursos visuais.
- Jogador interage diretamente nos elementos do cenário. Não apresentar menus de ações como “examinar carta”.
- Projetar para toque no celular, com suporte a mouse e teclado.

## Prólogo: O Último Trem
1. Vagão em movimento com chuva, iluminação oscilante, parallax sutil e áudio ambiental.
2. Envelope na mesa: hotspot no próprio objeto; aproximação; abrir; ler; guardar.
3. Após leitura, encontro com condutor. Diálogo contextual e legendas sem painel permanente.
4. Guarda-volumes: formulário de pistas examinável; três discos interativos com ordem MALA / ENVELOPE / CHAVE; feedback de erro e sucesso.
5. Estojo de Elara: fotografia, carta e medalhão examináveis; pistas preservadas para a continuidade.

## Arquitetura de interação
- Cena base e camadas de cenário, efeitos, objetos e interface.
- Hotspots com áreas coerentes com a silhueta visual; indicador sutil apenas ao toque ou solicitação de dica.
- Close-up de objetos com fechar/voltar consistente; sem bloquear inventário indevidamente.
- Inventário compacto, inicialmente recolhido, com itens examináveis e combináveis quando o roteiro permitir.
- Estado persistente: carta lida, itens recolhidos, discos, estojo aberto, cenas visitadas.
- Sistema de legendas temporárias e avanço de diálogo, com opção de acessibilidade.
- Transições suaves, sem animações que atrasem repetidamente o jogador.
- Área segura em telas pequenas e orientação responsiva; hotspots calibrados para coordenadas de cena, não para pixels de tela.

## Critérios de aceitação
- Nenhuma ação principal depende de botão textual fora do cenário.
- O envelope pode ser aberto por toque no próprio envelope.
- O enigma pode ser resolvido explorando pistas, sem adivinhação.
- Inventário não encobre elementos críticos.
- Reinício restaura estado previsível; progresso não se perde ao alternar orientação.
- A história e as falas aprovadas não são reescritas sem revisão.
- Cenários finais exigem assets autorais aprovados; formas geométricas atuais são apenas placeholders.

## Sequência de implementação
1. Motor de hotspots, close-ups, inventário e legendas.
2. Revisão da cena do envelope e da câmera.
3. Integração do condutor e do guarda-volumes.
4. Inserção dos assets finais e animações ambientais.
5. Testes em celular e publicação após aprovação.
