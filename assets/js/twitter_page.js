let TwitterPage = {
    init(socket) {
      let channel = socket.channel('twitter_page:lobby', {})
      channel.join()
      this.listenForChats(channel)
    },
  
    listenForChats(channel) {
      document.getElementById('tweet-btn').addEventListener('click', function(e){
        e.preventDefault()
        let userMsg = document.getElementById('tweet-msg').value
        channel.push('tweet', {body: userMsg})
        document.getElementById('tweet-msg').value = ''
      })

      document.getElementById('retweet-btn').addEventListener('click', function(e){
        e.preventDefault()
        let tweetId = document.getElementById('tweet-id').value
        channel.push('retweet', {body: tweetId})
        document.getElementById('tweet-id').value = ''
      })
  
      channel.on('tweet', payload => {
        let chatBox = document.querySelector('#chat-box')
        let msgBlock = document.createElement('p')
  
        msgBlock.insertAdjacentHTML('beforeend', `${payload.id} -> ${payload.msg}`)
        chatBox.appendChild(msgBlock)
      })

      channel.on('twitter:joined', payload => {
        let chatBox = document.querySelector('#chat-box')
        let msgBlock = document.createElement('p')
  
        msgBlock.insertAdjacentHTML('beforeend', `${payload.msg}`) 
        chatBox.appendChild(msgBlock)
      })
    }
  }
  
  export default TwitterPage