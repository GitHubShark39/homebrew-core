class WlaDx < Formula
  desc "Yet another crossassembler package"
  homepage "https://github.com/vhelin/wla-dx"
  url "https://github.com/vhelin/wla-dx/archive/v9.6.tar.gz"
  sha256 "d368f4fb7d8a394f65730682dba6fddfe75b3c6119756799cdb3cd5e1ae78e0d"

  bottle do
    cellar :any_skip_relocation
    sha256 "4c82ca3dac46329d7eb3338789e1ededec6f8828e9d52b8607ff6448ab0a06fa" => :high_sierra
    sha256 "1f55a4e132ec1fb82ad09334af83dbf08d1c30ad2ba828392c42fc54f5899cc7" => :sierra
    sha256 "80c729c545582ba83294b3a4cadd23ef378f4e71daa49220812ab149aa66f49b" => :el_capitan
    sha256 "4c192ebb6538da0313496f6927a52f7a64782dbeedbf454b0004e203ddb2109e" => :yosemite
    sha256 "2b8cf1da40e1ce9fedbbf41277ee44955fa99712d46c2fb8d6140c8452b74445" => :mavericks
    sha256 "a78744385e31896de6b34ae3426c6081ada2f28b997f0c5c15555e10bd03d53e" => :mountain_lion
  end

  head do
    url "https://github.com/vhelin/wla-dx.git"

    depends_on "cmake" => :build
  end

  def install
    if build.stable?
      %w[CFLAGS CXXFLAGS CPPFLAGS].each { |e| ENV.delete(e) }
      ENV.append_to_cflags "-c -O3 -ansi -pedantic -Wall"

      chmod 0755, "unix.sh"
      system "./unix.sh", ENV.make_jobs
      bin.install Dir["./binaries/*"]
    else
      system "cmake", ".", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test-gb-asm.s").write <<-EOS.undent
     .MEMORYMAP
      DEFAULTSLOT 1.01
      SLOT 0.001 $0000 $2000
      SLOT 1.2 STArT $2000 sIzE $6000
      .ENDME

      .ROMBANKMAP
      BANKSTOTAL 2
      BANKSIZE $2000
      BANKS 1
      BANKSIZE $6000
      BANKS 1
      .ENDRO

      .BANK 1 SLOT 1

      .ORGA $2000


      ld hl, sp+127
      ld hl, sp-128
      add sp, -128
      add sp, 127
      adc 200
      jr -128
      jr 127
      jr nc, 127
    EOS
    system bin/"wla-gb", "-o", testpath/"test-gb-asm.s"
  end
end
