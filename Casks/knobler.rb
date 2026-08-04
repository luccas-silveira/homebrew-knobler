cask "knobler" do
  version "0.21.0"
  sha256 "6b463dbb80aa1898863d4cbaafa9e8de9bd44a9f62e8e28d6ffbfb3f0393a46e"

  url "https://github.com/luccas-silveira/knobler/releases/download/v#{version}/Knobler-#{version}.zip"
  name "Knobler"
  desc "Dynamic Island for the Mac notch"
  homepage "https://github.com/luccas-silveira/knobler"

  depends_on macos: :sonoma

  app "Knobler.app"

  # App é self-signed (cert próprio, estável entre versões) e não-notarizado, e a
  # --no-quarantine foi removida no Homebrew 5.1; remover a quarantine aqui, senão
  # o Gatekeeper bloqueia o 1º launch. Some quando houver Developer ID + notarização.
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
    ASSINATURA
    O Knobler é assinado com um certificado próprio e NÃO é notarizado pela Apple.
    O macOS não consegue confirmar quem publicou o app, então bloquearia o primeiro
    launch; este cask removeu a marca de quarentena no install para contornar isso.
    Se preferir não depender de um instalador para esse passo, use o zip do
    Releases e remova a marca você mesmo, depois de conferir o que está instalando:
      xattr -dr com.apple.quarantine "#{appdir}/Knobler.app"

    PERMISSÕES
    Pedidas no primeiro uso de cada recurso, e recusar só desliga aquele recurso.
    O estado de todas fica em Ajustes → Permissões.
      • Acessibilidade — teclas de volume/brilho, gatilho do ditado, colar o texto
        (única pedida na abertura: sem ela o gatilho do ditado não chega ao app)
      • Microfone, Câmera, Calendários, Rede local, Arquivos e pastas,
        Gravação de Áudio do Sistema
      • Bluetooth — detectar a conexão dos AirPods pra mostrar a bateria
        (pedida logo após a abertura, se o recurso estiver ligado)
    Não pede Automação nem Gravação de Tela.

    Formatação de transcript com IA (opcional): brew install ollama && ollama pull gemma3:4b
  EOS
end
