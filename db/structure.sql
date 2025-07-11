SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: prevent_update_if_finalized(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_update_if_finalized() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF OLD.finalized = true THEN
          RAISE EXCEPTION 'Cannot update a finalized event';
        END IF;
        RETURN NEW;
      END;
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_attack_solutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_attack_solutions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_contestation_submitted_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_contestation_submitted_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    arbius_ethereum_event_details_id uuid NOT NULL,
    address character varying NOT NULL,
    task character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_contestation_vote_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_contestation_vote_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    arbius_ethereum_event_details_id uuid NOT NULL,
    address character varying NOT NULL,
    task character varying NOT NULL,
    yea boolean NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_contestation_vote_finish_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_contestation_vote_finish_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    arbius_ethereum_event_details_id uuid NOT NULL,
    task_id character varying NOT NULL,
    start_idx integer NOT NULL,
    end_idx integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_ethereum_event_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_ethereum_event_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ethereum_event_id uuid NOT NULL,
    block_hash character varying NOT NULL,
    block_number integer NOT NULL,
    chain_id integer NOT NULL,
    contract_address character varying NOT NULL,
    transaction_hash character varying NOT NULL,
    transaction_index integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_job_execution_trackers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_job_execution_trackers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    job_name character varying NOT NULL,
    last_executed_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_miner_contestation_vote_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_miner_contestation_vote_checks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_miners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_miners (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_sent_contestation_vote_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_sent_contestation_vote_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address character varying NOT NULL,
    task character varying NOT NULL,
    yea boolean NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL
);


--
-- Name: arbius_signal_commitment_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_signal_commitment_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    arbius_ethereum_event_details_id uuid NOT NULL,
    address character varying NOT NULL,
    commitment character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_solution_claimed_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_solution_claimed_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    arbius_ethereum_event_details_id uuid NOT NULL,
    address character varying NOT NULL,
    task character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_solution_submitted_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_solution_submitted_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    arbius_ethereum_event_details_id uuid NOT NULL,
    address character varying NOT NULL,
    task character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_task_submitted_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_task_submitted_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    arbius_ethereum_event_details_id uuid NOT NULL,
    task_id character varying NOT NULL,
    model character varying NOT NULL,
    fee numeric(78,0) NOT NULL,
    sender character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: arbius_validators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arbius_validators (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ethereum_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ethereum_addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ethereum_event_poller_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ethereum_event_poller_states (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    poller_name character varying NOT NULL,
    last_processed_block integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ethereum_event_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ethereum_event_topics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ethereum_event_id uuid NOT NULL,
    topic_index integer NOT NULL,
    topic character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ethereum_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ethereum_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address character varying NOT NULL,
    block_hash character varying NOT NULL,
    block_number bigint NOT NULL,
    transaction_hash character varying NOT NULL,
    transaction_index integer NOT NULL,
    log_index integer NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    data character varying NOT NULL,
    chain_id integer NOT NULL,
    finalized boolean DEFAULT false NOT NULL,
    raw_event jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ethereum_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ethereum_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "from" character varying NOT NULL,
    "to" character varying NOT NULL,
    value numeric(78,0),
    chain_id integer NOT NULL,
    nonce integer,
    data text,
    tx_hash character varying,
    raw_tx text,
    signed_tx text,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    broadcasted_at timestamp without time zone,
    confirmed_at timestamp without time zone,
    context json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flipper_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_features (
    id bigint NOT NULL,
    key character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flipper_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_features_id_seq OWNED BY public.flipper_features.id;


--
-- Name: flipper_gates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_gates (
    id bigint NOT NULL,
    feature_key character varying NOT NULL,
    key character varying NOT NULL,
    value text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_gates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_gates_id_seq OWNED BY public.flipper_gates.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: flipper_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features ALTER COLUMN id SET DEFAULT nextval('public.flipper_features_id_seq'::regclass);


--
-- Name: flipper_gates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates ALTER COLUMN id SET DEFAULT nextval('public.flipper_gates_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: arbius_attack_solutions arbius_attack_solutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_attack_solutions
    ADD CONSTRAINT arbius_attack_solutions_pkey PRIMARY KEY (id);


--
-- Name: arbius_contestation_submitted_events arbius_contestation_submitted_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_contestation_submitted_events
    ADD CONSTRAINT arbius_contestation_submitted_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_contestation_vote_events arbius_contestation_vote_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_contestation_vote_events
    ADD CONSTRAINT arbius_contestation_vote_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_contestation_vote_finish_events arbius_contestation_vote_finish_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_contestation_vote_finish_events
    ADD CONSTRAINT arbius_contestation_vote_finish_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_ethereum_event_details arbius_ethereum_event_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_ethereum_event_details
    ADD CONSTRAINT arbius_ethereum_event_details_pkey PRIMARY KEY (id);


--
-- Name: arbius_job_execution_trackers arbius_job_execution_trackers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_job_execution_trackers
    ADD CONSTRAINT arbius_job_execution_trackers_pkey PRIMARY KEY (id);


--
-- Name: arbius_miner_contestation_vote_checks arbius_miner_contestation_vote_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_miner_contestation_vote_checks
    ADD CONSTRAINT arbius_miner_contestation_vote_checks_pkey PRIMARY KEY (id);


--
-- Name: arbius_miners arbius_miners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_miners
    ADD CONSTRAINT arbius_miners_pkey PRIMARY KEY (id);


--
-- Name: arbius_sent_contestation_vote_events arbius_sent_contestation_vote_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_sent_contestation_vote_events
    ADD CONSTRAINT arbius_sent_contestation_vote_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_signal_commitment_events arbius_signal_commitment_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_signal_commitment_events
    ADD CONSTRAINT arbius_signal_commitment_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_solution_claimed_events arbius_solution_claimed_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_solution_claimed_events
    ADD CONSTRAINT arbius_solution_claimed_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_solution_submitted_events arbius_solution_submitted_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_solution_submitted_events
    ADD CONSTRAINT arbius_solution_submitted_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_task_submitted_events arbius_task_submitted_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_task_submitted_events
    ADD CONSTRAINT arbius_task_submitted_events_pkey PRIMARY KEY (id);


--
-- Name: arbius_validators arbius_validators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.arbius_validators
    ADD CONSTRAINT arbius_validators_pkey PRIMARY KEY (id);


--
-- Name: ethereum_addresses ethereum_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_addresses
    ADD CONSTRAINT ethereum_addresses_pkey PRIMARY KEY (id);


--
-- Name: ethereum_event_poller_states ethereum_event_poller_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_event_poller_states
    ADD CONSTRAINT ethereum_event_poller_states_pkey PRIMARY KEY (id);


--
-- Name: ethereum_event_topics ethereum_event_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_event_topics
    ADD CONSTRAINT ethereum_event_topics_pkey PRIMARY KEY (id);


--
-- Name: ethereum_events ethereum_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_events
    ADD CONSTRAINT ethereum_events_pkey PRIMARY KEY (id);


--
-- Name: ethereum_transactions ethereum_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_transactions
    ADD CONSTRAINT ethereum_transactions_pkey PRIMARY KEY (id);


--
-- Name: flipper_features flipper_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features
    ADD CONSTRAINT flipper_features_pkey PRIMARY KEY (id);


--
-- Name: flipper_gates flipper_gates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates
    ADD CONSTRAINT flipper_gates_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: idx_on_arbius_ethereum_event_details_id_c11a1c7990; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_arbius_ethereum_event_details_id_c11a1c7990 ON public.arbius_task_submitted_events USING btree (arbius_ethereum_event_details_id);


--
-- Name: index_arbius_attack_solutions_on_task; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_arbius_attack_solutions_on_task ON public.arbius_attack_solutions USING btree (task);


--
-- Name: index_arbius_contestation_submitted_events_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_contestation_submitted_events_on_address ON public.arbius_contestation_submitted_events USING btree (address);


--
-- Name: index_arbius_contestation_submitted_events_on_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_contestation_submitted_events_on_task ON public.arbius_contestation_submitted_events USING btree (task);


--
-- Name: index_arbius_contestation_vote_events_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_contestation_vote_events_on_address ON public.arbius_contestation_vote_events USING btree (address);


--
-- Name: index_arbius_contestation_vote_events_on_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_contestation_vote_events_on_task ON public.arbius_contestation_vote_events USING btree (task);


--
-- Name: index_arbius_contestation_vote_finish_events_on_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_contestation_vote_finish_events_on_task_id ON public.arbius_contestation_vote_finish_events USING btree (task_id);


--
-- Name: index_arbius_ethereum_event_details_on_ethereum_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_arbius_ethereum_event_details_on_ethereum_event_id ON public.arbius_ethereum_event_details USING btree (ethereum_event_id);


--
-- Name: index_arbius_ethereum_event_details_on_transaction_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_ethereum_event_details_on_transaction_hash ON public.arbius_ethereum_event_details USING btree (transaction_hash);


--
-- Name: index_arbius_job_execution_trackers_on_job_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_arbius_job_execution_trackers_on_job_name ON public.arbius_job_execution_trackers USING btree (job_name);


--
-- Name: index_arbius_miner_contestation_vote_checks_on_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_arbius_miner_contestation_vote_checks_on_task_id ON public.arbius_miner_contestation_vote_checks USING btree (task_id);


--
-- Name: index_arbius_miners_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_arbius_miners_on_address ON public.arbius_miners USING btree (address);


--
-- Name: index_arbius_sent_contestation_vote_events_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_sent_contestation_vote_events_on_address ON public.arbius_sent_contestation_vote_events USING btree (address);


--
-- Name: index_arbius_sent_contestation_vote_events_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_sent_contestation_vote_events_on_status ON public.arbius_sent_contestation_vote_events USING btree (status);


--
-- Name: index_arbius_sent_contestation_vote_events_on_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_sent_contestation_vote_events_on_task ON public.arbius_sent_contestation_vote_events USING btree (task);


--
-- Name: index_arbius_sent_contestation_vote_events_on_task_and_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_arbius_sent_contestation_vote_events_on_task_and_address ON public.arbius_sent_contestation_vote_events USING btree (task, address);


--
-- Name: index_arbius_signal_commitment_events_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_signal_commitment_events_on_address ON public.arbius_signal_commitment_events USING btree (address);


--
-- Name: index_arbius_signal_commitment_events_on_commitment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_signal_commitment_events_on_commitment ON public.arbius_signal_commitment_events USING btree (commitment);


--
-- Name: index_arbius_solution_claimed_events_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_solution_claimed_events_on_address ON public.arbius_solution_claimed_events USING btree (address);


--
-- Name: index_arbius_solution_claimed_events_on_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_solution_claimed_events_on_task ON public.arbius_solution_claimed_events USING btree (task);


--
-- Name: index_arbius_solution_submitted_events_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_solution_submitted_events_on_address ON public.arbius_solution_submitted_events USING btree (address);


--
-- Name: index_arbius_solution_submitted_events_on_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_solution_submitted_events_on_task ON public.arbius_solution_submitted_events USING btree (task);


--
-- Name: index_arbius_task_submitted_events_on_sender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_task_submitted_events_on_sender ON public.arbius_task_submitted_events USING btree (sender);


--
-- Name: index_arbius_task_submitted_events_on_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_arbius_task_submitted_events_on_task_id ON public.arbius_task_submitted_events USING btree (task_id);


--
-- Name: index_arbius_validators_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_arbius_validators_on_address ON public.arbius_validators USING btree (address);


--
-- Name: index_eth_event_topics_on_event_and_topic_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_eth_event_topics_on_event_and_topic_index ON public.ethereum_event_topics USING btree (ethereum_event_id, topic_index);


--
-- Name: index_eth_events_on_chain_block_log; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_eth_events_on_chain_block_log ON public.ethereum_events USING btree (chain_id, block_hash, log_index);


--
-- Name: index_eth_tx_on_from_chainid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eth_tx_on_from_chainid ON public.ethereum_transactions USING btree ("from", chain_id);


--
-- Name: index_eth_tx_on_from_chainid_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eth_tx_on_from_chainid_status_created ON public.ethereum_transactions USING btree ("from", chain_id, status, created_at);


--
-- Name: index_ethereum_addresses_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ethereum_addresses_on_address ON public.ethereum_addresses USING btree (address);


--
-- Name: index_ethereum_event_poller_states_on_poller_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ethereum_event_poller_states_on_poller_name ON public.ethereum_event_poller_states USING btree (poller_name);


--
-- Name: index_ethereum_event_topics_on_ethereum_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ethereum_event_topics_on_ethereum_event_id ON public.ethereum_event_topics USING btree (ethereum_event_id);


--
-- Name: index_ethereum_transactions_on_tx_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ethereum_transactions_on_tx_hash ON public.ethereum_transactions USING btree (tx_hash);


--
-- Name: index_flipper_features_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_features_on_key ON public.flipper_features USING btree (key);


--
-- Name: index_flipper_gates_on_feature_key_and_key_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_gates_on_feature_key_and_key_and_value ON public.flipper_gates USING btree (feature_key, key, value);


--
-- Name: ethereum_events prevent_update_if_finalized_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER prevent_update_if_finalized_trigger BEFORE UPDATE ON public.ethereum_events FOR EACH ROW EXECUTE FUNCTION public.prevent_update_if_finalized();


--
-- Name: ethereum_event_topics fk_rails_84f67e4727; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ethereum_event_topics
    ADD CONSTRAINT fk_rails_84f67e4727 FOREIGN KEY (ethereum_event_id) REFERENCES public.ethereum_events(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250708000918'),
('20250707040900'),
('20250706130853'),
('20250706023424'),
('20250701120000'),
('20250628120000'),
('20250627020000'),
('20250627013615'),
('20250627001326'),
('20250626235632'),
('20250625120000'),
('20250623130000'),
('20250623120000'),
('20250618000000');

