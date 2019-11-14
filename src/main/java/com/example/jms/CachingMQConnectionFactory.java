package com.example.jms;

import com.ibm.mq.jms.MQQueueConnectionFactory;
import com.ibm.mq.jms.MQQueueConnectionFactoryFactory;
import org.apache.log4j.Logger;
import org.messaginghub.pooled.jms.JmsPoolConnectionFactory;

import javax.naming.*;
import javax.naming.spi.ObjectFactory;
import java.util.Enumeration;
import java.util.Hashtable;

/**
 * JmsPoolConnectionFactory for use in tomcat context. Wraps @com.ibm.mq.jms.MQQueueConnectionFactory
 */
public class CachingMQConnectionFactory implements ObjectFactory {

    private static final Logger LOGGER = Logger.getLogger(CachingMQConnectionFactory.class);

    public Object getObjectInstance(Object obj, Name name, Context nameCtx, Hashtable<?, ?> environment) throws NamingException {
        Reference ref = (Reference) obj;
        String beanClassName = ref.getClassName();
        Class<?> beanClass = null;
        try {
            beanClass = Class.forName(beanClassName);
        } catch (ClassNotFoundException e) {
            LOGGER.error("JMS init() Exception  " + e.getMessage());
        }
        MQQueueConnectionFactoryFactory cff = new MQQueueConnectionFactoryFactory();
        Reference mqReference = new Reference(MQQueueConnectionFactory.class.getName());

        Enumeration<RefAddr> allAddrs = ref.getAll();
        while (allAddrs.hasMoreElements()) {
            mqReference.add(allAddrs.nextElement());
        }

        MQQueueConnectionFactory cf = null;
        try {
            cf = (MQQueueConnectionFactory) cff.getObjectInstance(mqReference, name, nameCtx, environment);
        } catch (Exception e) {
            LOGGER.error("JMS MQQueueConnectionFactory init() Exception  " + e.getMessage());
        }
        JmsPoolConnectionFactory pcf = new JmsPoolConnectionFactory();
        pcf.setMaxConnections(5);
        pcf.setConnectionFactory(cf);
        return pcf;
    }
}
