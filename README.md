# OpenFortiVPN Indicator

Ícone na barra de tarefas (system tray) do Ubuntu/GNOME para controlar o
[`openfortivpn`](https://github.com/adrienverge/openfortivpn) e mostrar
**graficamente** o estado do túnel:

| Ícone | Estado |
|-------|--------|
| 🟢 escudo com "✓" | **Conectado** (interface `pppN` ativa) |
| 🟠 escudo com "…" | **Conectando** (serviço subindo / autenticando) |
| ⚪ escudo com "✕" | **Desconectado** |

As credenciais/endereço vêm do **arquivo de configuração padrão da CLI**:
`/etc/openfortivpn/config` — o mesmo que você usaria com
`sudo openfortivpn`. O indicador não guarda configuração própria.

## Como funciona

- Um serviço systemd de sistema (`openfortivpn-indicator.service`) roda
  `openfortivpn -c /etc/openfortivpn/config` com privilégios de root.
- O ícone da bandeja (app GTK do usuário) apenas dá `start`/`stop` nesse
  serviço e faz *polling* do estado a cada 3 s.
- Uma regra polkit (`/usr/share/polkit-1/rules.d/50-openfortivpn-indicator.rules`)
  permite que membros do grupo `sudo` liguem/desliguem **apenas esse
  serviço** sem digitar a senha toda vez. Sem a regra, o app cai
  automaticamente para o `pkexec` (que pede a senha).

## Instalar

```sh
./build.sh                    # gera openfortivpn-indicator_1.0.0_all.deb
sudo apt install ./openfortivpn-indicator_1.0.0_all.deb
```

Depois configure a VPN (uma vez), com os dados da sua organização:

```sh
sudo nano /etc/openfortivpn/config    # ou use "Editar configuração…" no menu do ícone
sudo chmod 600 /etc/openfortivpn/config
```

Exemplo de `/etc/openfortivpn/config`:

```ini
host = vpn.suaempresa.com
port = 443
username = seu.usuario
password = sua_senha
trusted-cert = <hash do certificado, se necessário>
```

## Usar

O indicador inicia sozinho no login (autostart). Também está no menu de
aplicativos como **"OpenFortiVPN Indicator"**. No menu do ícone:

- **Conectar / Desconectar** — sobe/derruba o túnel.
- **Ver log…** — últimas linhas de `journalctl -u openfortivpn-indicator`.
- **Editar configuração…** — abre `/etc/openfortivpn/config` como root.
- **Sair** — fecha o ícone (não derruba a VPN).

> No GNOME "puro" pode ser necessária a extensão *AppIndicator and
> KStatusNotifierItem Support* para exibir ícones de bandeja. No Ubuntu
> padrão (com a extensão da Ubuntu) já funciona.

## Desinstalar

```sh
sudo apt remove openfortivpn-indicator
```

O túnel é derrubado automaticamente na remoção. O arquivo
`/etc/openfortivpn/config` é preservado.

## Estrutura do projeto

```
package/
├── DEBIAN/                     control + scripts de manutenção
├── etc/xdg/autostart/          inicia o ícone no login
└── usr/
    ├── bin/openfortivpn-indicator          app GTK (Python)
    ├── lib/systemd/system/….service        serviço que roda o openfortivpn
    └── share/
        ├── applications/….desktop          entrada no menu
        ├── openfortivpn-indicator/icons/   ícones dos 3 estados (SVG)
        └── polkit-1/rules.d/….rules        autorização sem senha
build.sh                        empacota tudo num .deb
```
