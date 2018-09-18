module FileSizeHelper
  def human_filesize(bytes)
    amount, units = bytes, 'bytes'
    kilos = bytes / 1024
    if kilos > 1
      amount, units = kilos, 'KB'
      megas = kilos / 1024
      if megas > 1
        amount, units = megas, 'MB'
        gigas = megas / 1024
        if gigas > 1
          amount, units = gigas, 'GB'
        end
      end
    end
    "#{amount} #{units}"
  end
end
