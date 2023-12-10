import { useCallback, useEffect, useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import useSWR from 'swr';

const fetcher = (...args) => fetch(...args).then(res => res.json())
const DEFAULT_LIMIT = 10;

function useDocuments() {
  const [pageSize, setPageSize] = useState(DEFAULT_LIMIT);
  const [page, setPage] = useState(1);
  const [query, setQuery] = useState("");

  const url = useMemo(() => `https://localhost/documents?query=${encodeURIComponent(query)}&limit=${pageSize}&offset=${(page - 1) * pageSize}`, [query, pageSize, page]);
  const { data, error, isLoading } = useSWR(url, fetcher)

  const documents = useMemo(() => (data?.hits?.hits || []).map((hit) => ({ ...hit._source })), [data]);
  const totalDocuments = useMemo(() => data?.hits?.total?.value || 0, [data]);
  const totalPages = useMemo(() => totalDocuments > 0 ? Math.ceil(totalDocuments / pageSize) : 0, [totalDocuments, pageSize]);

  const canFirstPage = useMemo(() => page > 1, [page]);
  const canNextPage = useMemo(() => pageSize * page < totalDocuments, [page, pageSize, totalDocuments]);
  const canPrevPage = useMemo(() => page > 1, [page]);
  const canLastPage = useMemo(() => page < totalPages, [page, totalPages]);

  const firstPage = useCallback(() => setPage(1));
  const lastPage = useCallback(() => setPage(totalPages));
  const nextPage = useCallback(() => setPage(page + 1), [page]);
  const prevPage = useCallback(() => setPage(Math.max(1, page - 1)), [page]);

  useEffect(() => {
    setPage(1);
  }, [query, pageSize]);

  return {
    documents,
    totalDocuments,
    filterState: {
      query,
      setQuery
    },
    paginationState: {
      page,
      pageSize,
      setPageSize,
      firstPage,
      nextPage,
      prevPage,
      lastPage,
      canFirstPage,
      canNextPage,
      canPrevPage,
      canLastPage,
      totalPages,
    },
    error,
    isLoading
  };
}

function Search({ filterState, ...props }) {
  const [search, setSearch] = useState("");
  const { setQuery } = filterState;

  useEffect(() => {
    const debounce = setTimeout(() => setQuery(search), 1000);
    return () => clearTimeout(debounce);
  }, [search]);

  return <div {...props}>
    <input type="text" value={search} placeholder="Search" style={{ minWidth: "20%" }} onChange={(e) => setSearch(e.target.value)}></input>
  </div>;
}

function DocumentTable({ documents, ...props }) {
  const headers = Object.keys(documents[0] || {});

  return headers.length > 0 ? <table  {...props}>
    <thead>
      <tr>
        {headers.map((key) => <th key={key}>{key}</th>)}
      </tr>
    </thead>

    <tbody>
      {documents.map((row, i) => <tr key={i}>
        {headers.map((key) => <td key={key}><p>{row[key]?.slice(0, 100)}</p></td>)}
      </tr>)}
    </tbody>
  </table> : <></>
}

function DocumentTableControls({ isLoading, totalDocuments, paginationState, ...props }) {
  return <div {...props}>
    
    {isLoading ? <p>Loading...</p> : <>
      <p>Page: {paginationState.page} / {paginationState.totalPages} </p>
      <p>Total Results: {totalDocuments}</p>
    </>}

    <div style={{ display: "flex", flexDirection: "row" }}>
      <button onClick={paginationState.firstPage} disabled={!paginationState.canFirstPage}>First Page</button>
      <button onClick={paginationState.prevPage} disabled={!paginationState.canPrevPage}>Previous Page</button>
      <button onClick={paginationState.nextPage} disabled={!paginationState.canNextPage}>Next Page</button>
      <button onClick={paginationState.lastPage} disabled={!paginationState.canLastPage}>Last Page</button>
      <select name="Page Size" onChange={(e) => paginationState.setPageSize(Number(e.target.value))}>
        <option value="10">10</option>
        <option value="20">20</option>
        <option value="50">50</option>
        <option value="100">100</option>
      </select>
    </div>
  </div>
}

function App() {
  const { documents, totalDocuments, filterState, paginationState, error, isLoading } = useDocuments();

  return (
    <div id="docusearch-app-container" style={{ margin: "1rem", display: "flex", flexDirection: "column", justifyContent: "center" }}>
      <h1 style={{ display: "flex", justifyContent: "center" }}>Docusearch</h1>

      <Search id="docusearch-searchbar" filterState={filterState} style={{ display: "flex", justifyContent: "center" }} />
      <DocumentTableControls isLoading={isLoading} totalDocuments={totalDocuments} paginationState={paginationState} style={{ display: "flex", flexDirection: "column", margin: "1rem" }} />
      <DocumentTable id="docusearch-table" documents={documents} style={{ marginTop: "1rem" }} />
    </div>
  );
}

const root = createRoot(document.getElementById('root'));
root.render(<App />);
