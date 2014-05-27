# ImapFlagCopy
This script is intended for internal use when we do imap data migration and lost message flags.
It transverses the mailbox, gets the message flags,  and copies back to the target mailbox destination if the same message exists. (via message-id)


## Prerequisite
- ruby
- sinatra
- thin
- highline
- rack


## How to use.
1.  by command line

    ```
    Usage: ./imap_copy.rb [options] <username>
        --host1 HOST (localhost)
        --host2 HOST (192.168.200.1)
        --folder FOLDER (optional)
        --password PASSWORD  (optional)
        --unseen  (optional)
    ```

    - *password* - use when you wants batch processing. If this option is not set. there will be prompt for password.
    - *unseen* - search only  message with flagged, answered, $forward , and unseen flags.  If this options is not set, all message will be used.
    - *host1* - source host
    - *host2* - destination host
2.  by webui
    You can start by using thin.   Please, edit configuration in config.yml before use.

    ```
    thin -s 2 -C config.yml -R config.ru restart
    ```
