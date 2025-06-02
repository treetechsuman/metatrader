#ifndef UTILS_MQH
#define UTILS_MQH

void LogMessage(string message)
{
    PrintFormat("[%s] %s", TimeToString(TimeCurrent(), TIME_SECONDS), message);
}

#endif
