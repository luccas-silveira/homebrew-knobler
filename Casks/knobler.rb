cask "knobler" do
  version "0.3.0"
  sha256 "d036882509030cdab6a5218fdf89ce26d86a374447d92d81cc0a0bd306c6b272"

  url "https://github.com/luccas-silveira/knobler/releases/download/v#{version}/Knobler-#{version}.zip"
  name "Knobler"
  desc "Dynamic Island for the Mac notch"
  homepage "https://github.com/luccas-silveira/knobler"

  depends_on macos: :sonoma

  app "Knobler.app"

  # App é ad-hoc/não-notarizado e --no-quarantine foi removida no Homebrew 5.1;
  # remover a quarantine aqui, senão o Gatekeeper bloqueia o 1º launch.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Knobler.app"]
    # provisiona o modelo de ditado (~600MB) já no install — 1º ditado instantâneo.
    # best-effort: offline não quebra a instalação (o launch baixa como fallback).
    system_command "#{appdir}/Knobler.app/Contents/MacOS/Knobler",
                   args:         ["--download-model"],
                   print_stdout: true,
                   print_stderr: false, # esconde o ruído [INFO] do FluidAudio; progresso vai no stdout
                   must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/FluidAudio", # modelo Parakeet (~600MB) baixado no 1º ditado
    "~/Library/Caches/com.zoi.knobler",
    "~/Library/HTTPStorages/com.zoi.knobler",
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
