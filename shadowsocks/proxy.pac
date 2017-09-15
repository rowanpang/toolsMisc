function FindProxyForURL(url, host) {
    var autoproxy = 'SOCKS 10.4.11.26:1081';
    return autoproxy;

    if (dnsDomainIs(host, '.google.com') ||
        dnsDomainIs(host, '.google.com.hk') ||
        dnsDomainIs(host, '.sourceforge.net') ||
        host == 'wp.me' ||
        host == 'ow.ly' ||
        host == 'po.st' ||
        host == 'goo.gl') {
        return autoproxy;
    }

    //return FindProxyForURLByAutoProxy(url, host);
    return "DIRECT"
}

function FindProxyForURLByAutoProxy(url, host) {
    if (url.indexOf("http://ime.baidu.jp") == 0) return "DIRECT";
    if (url.indexOf("https://autoproxy.org") == 0) return "DIRECT";
    if (dnsDomainIs(host, ".zhongsou.com") || host == "zhongsou.com") return "DIRECT";
    if (dnsDomainIs(host, ".youdao.com") || host == "youdao.com") return "DIRECT";
    if (dnsDomainIs(host, ".yahoo.cn") || host == "yahoo.cn") return "DIRECT";
    if (dnsDomainIs(host, ".soso.com") || host == "soso.com") return "DIRECT";
    if (dnsDomainIs(host, ".so.com") || host == "so.com") return "DIRECT";

    return "DIRECT"
}
