platform :ios, '11.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def common_pods
    pod 'CTFeedback'
    pod 'pop'
    pod 'TTCounterLabel'
    pod 'CocoaAsyncSocket'
    pod 'RPCircularProgress'
    pod 'MPGNotification'
end

target 'TriggertrapSLR Mac' do
    common_pods
end

target 'TriggertrapSLR' do
    common_pods
    pod 'GPUImage'
end
