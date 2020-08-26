function read-com {
    $port= new-Object System.IO.Ports.SerialPort COM4,9600,None,8,one
    $port.Open()
    $line= $port.ReadLine()
    Write-Output $line
    $line= $port.ReadLine()
    Write-Output $line
}