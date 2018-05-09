Write-EventLog -LogName "Application" -Source "AutoDVDRip" -EventId 2 -EntryType Information -Message "Unregistering event."
Try
{
    Unregister-Event -SourceIdentifier discInserted
}
Catch
{
    # todo: this is not logging on exception
    Write-EventLog -LogName "Application" -Source "AutoDVDRip" -EventId 103 -EntryType Error -Message "Error encountered while unregistering event."
    Break
}
