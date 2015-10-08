cask :v1 => 'conductor' do
  version '1.2.2'
  sha256 'a5f9ba34c258c7d6a902de86c4f14e36e0b6283ab3893d6c43a7ba95f3831e63'

  url 'https://github.com/keith/conductor/releases/download/1.2.2/Conductor.app.zip'
  name 'Conductor'
  homepage 'https://github.com/keith/conductor'
  license :mit

  app 'Conductor.app'
end
