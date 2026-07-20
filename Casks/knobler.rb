cask "knobler" do
  version "0.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/luccas-silveira/knobler/releases/download/v#{version}/Knobler-#{version}.zip"
  name "Knobler"
  desc "Dynamic Island for the Mac notch"
  homepage "https://github.com/luccas-silveira/knobler"

  depends_on macos: ">= :sonoma"

  app "Knobler.app"

  # App é ad-hoc/não-notarizado e --no-quarantine foi removida no Homebrew 5.1;
  # remover a quarantine aqui, senão o Gatekeeper bloqueia o 1º launch.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Knobler.app"]
  end

  zap trash: [
    "~/Library/Preferences/com.zoi.knobler.plist",
  ]

  caveats <<~EOS
    O Knobler é assinado ad-hoc (sem Developer ID/notarização). O Homebrew remove a
    quarentena automaticamente. Se algum dia o macOS ainda bloquear (ex.: app
    re-baixado por fora do brew), rode:
      xattr -dr com.apple.quarantine "#{appdir}/Knobler.app"

    Conceda em Ajustes do Sistema → Privacidade e Segurança:
      • Acessibilidade (teclas de ditado + notificações no notch)
      • Gravação de Áudio do Sistema (visualizador)
    Automação (Spotify/Music), Calendário, Mic e Bluetooth são pedidos em runtime.

    Formatação de transcript com IA (opcional): brew install ollama && ollama pull gemma3:4b
  EOS
end
