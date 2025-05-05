CLS


Get-Counter -ErrorAction SilentlyContinue '\Process(*)\% Processor Time' | 
Select-Object -ExpandProperty countersamples| Select-Object -Property instancename, cookedvalue | 
Where {$_.instanceName -notmatch "^(idle|_total|system)$"} | 
Sort-Object -Property cookedvalue -Descending| Select-Object -First 10| 
ft InstanceName,@{L='CPU';E={($_.Cookedvalue/100/$env:NUMBER_OF_PROCESSORS).toString('P')}} -AutoSize
